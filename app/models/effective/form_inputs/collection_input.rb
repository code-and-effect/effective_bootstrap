module Effective
  module FormInputs
    class CollectionInput < Effective::FormInput
      def initialize(name, options, builder:, html_options: nil)
        super
        assign_options_collection!
        assign_options_collection_methods!
      end

      def polymorphic?
        return @polymorphic unless @polymorphic.nil?
        @polymorphic = (options.delete(:polymorphic) || false)
      end

      def grouped?
        return @grouped unless @grouped.nil?
        @grouped = (options.delete(:grouped) || false)
      end

      def collection_options
        return @collection_options unless @collection_options.nil?

        selected = options[:input].delete(:selected)
        passed_value = options[:input].delete(:value)
        include_blank = options[:input].delete(:include_blank)

        @collection_options = { selected: (selected || passed_value || value), include_blank: include_blank }
      end

      def html_options
        # Not sure why I need this. But they're merged in if I don't.
        options[:input].merge(skip_default_ids: nil, allow_method_names_outside_object: nil)
      end

      def value_method
        @value_method ||= options[:input].delete(:value_method)
      end

      def label_method
        @label_method ||= options[:input].delete(:label_method)
      end

      def group_method
        @group_method ||= options[:input].delete(:group_method)
      end

      def group_label_method
        @group_label_method ||= options[:input].delete(:group_label_method)
      end

      def option_key_method
        @option_key_method ||= options[:input].delete(:option_key_method)
      end

      def option_value_method
        @option_value_method ||= options[:input].delete(:option_value_method)
      end

      def options_collection
        @options_collection || []
      end

      # This is a grouped polymorphic collection
      # [["Clinics", [["Clinc 50", "Clinic_50"], ["Clinic 43", "Clinic_43"]]], ["Contacts", [["Contact 544", "Contact_544"]]]]
      def assign_options_collection!
        collection = options[:input].delete(:collection) || []

        grouped = collection[0].kind_of?(Array) && collection[0][0].kind_of?(String) && collection[0][1].respond_to?(:to_a) && (collection[0][1] != nil) # Array or ActiveRecord_Relation

        if grouped? && !grouped && collection.present?
          raise "Grouped collection expecting a Hash {'Posts' => Post.all, 'Events' => Event.all} or a Hash {'Posts' => [['Post A', 1], ['Post B', 2]], 'Events' => [['Event A', 1], ['Event B', 2]]}"
        end

        if grouped
          collection.each_with_index { |(name, group), index| collection[index][1] = group.respond_to?(:call) ? group.call : group.to_a }
        else
          collection = collection.respond_to?(:call) ? collection.call : collection.to_a
        end

        if polymorphic?
          if grouped
            collection.each { |_, group| polymorphize_collection!(group) }
          else
            polymorphize_collection!(collection)
          end
        end

        @options_collection = (collection.respond_to?(:call) ? collection.call : collection.to_a)
      end

      def assign_options_collection_methods!
        options[:input].reverse_merge!(
          if grouped? && polymorphic?
            { group_method: :first, group_label_method: :to_s, option_key_method: :id, option_value_method: :to_s }
          elsif grouped?
            { group_method: :first, group_label_method: :to_s, option_key_method: :id, option_value_method: :to_s }
          elsif options_collection[0].kind_of?(Array)
            { label_method: :first, value_method: :second }
          elsif options_collection[0].kind_of?(ActiveRecord::Base)
            { label_method: :to_s, value_method: :id }
          else
            { label_method: :to_s, value_method: :to_s }
          end
        )
      end

      # Translate our Collection into a polymorphic collection
      def polymorphize_collection!(collection)
        unless grouped? || collection[0].kind_of?(ActiveRecord::Base) || (collection[0].kind_of?(Array) && collection[0].length >= 2)
          raise "Polymorphic collection expecting a flat Array of mixed ActiveRecord::Base objects, or an Array of Arrays like [['Post A', 'Post_1'], ['Event B', 'Event_2']]"
        end

        collection.each_with_index do |obj, index|
          if obj.kind_of?(ActiveRecord::Base)
            collection[index] = [obj.to_s, "#{obj.class.model_name}_#{obj.id}"]
          end
        end
      end

      def polymorphic_type_method
        name.to_s.sub('_id', '') + '_type'
      end

      def polymorphic_id_method
        name.to_s.sub('_id', '') + '_id'
      end

      def polymorphic_value(obj)
        "#{object.class.model_name}_#{object.id}" if object
      end

      def polymorphic_type_value
        value.try(:class).try(:model_name)
      end

      def polymorphic_id_value
        value.try(:id)
      end

    end
  end
end
