# frozen_string_literal: true

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

      def custom? # default true
        return @custom unless @custom.nil?
        @custom = (options.delete(:custom) != false)
      end

      def inline? # default false
        return @inline unless @inline.nil?
        @inline = (options[:input].delete(:inline) == true)
      end

      def collection_options
        return @collection_options unless @collection_options.nil?

        checked = options[:input].delete(:checked)
        selected = options[:input].delete(:selected)
        include_blank = options[:input].delete(:include_blank)

        @collection_options = {
          checked: [checked, selected, polymorphic_value, value].find { |value| value != nil },
          selected: ([selected, checked, polymorphic_value, value].find { |value| value != nil } unless kind_of?(Effective::FormInputs::Radios)),
          include_blank: include_blank
        }.compact
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
        collection = options[:input].delete(:collection) || raise('Please include a collection')

        grouped = collection.kind_of?(Hash) && collection.values.first.respond_to?(:to_a)

        if grouped? && !grouped && collection.present?
          raise "Grouped collection expecting a Hash {'Posts' => Post.all, 'Events' => Event.all} or a Hash {'Posts' => [['Post A', 1], ['Post B', 2]], 'Events' => [['Event A', 1], ['Event B', 2]]}"
        end

        if polymorphic? && !grouped && collection.present?
          raise "Polymorphic collection expecting a Hash {'Posts' => Post.all, 'Events' => Event.all}"
        end

        @options_collection = (
          if polymorphic?
            collection.inject({}) { |h, (k, group)| h[k] = translate(group).map { |obj| [obj.to_s, "#{obj.class.model_name}_#{obj.id}"] }; h }
          elsif grouped
            collection.inject({}) { |h, (k, group)| h[k] = translate(group).map { |obj| obj }; h }
          elsif (collection == :boolean || collection == :booleans || collection == :boolean_collection)
            EffectiveBootstrap.boolean_collection
          else
            translate(collection).map { |obj| obj }
          end
        )
      end

      # Apply ActsAsArchived behavior. That's all for now.
      def translate(collection)
        return collection unless object.respond_to?(:new_record?)
        return collection unless collection.respond_to?(:klass)

        if collection.klass.respond_to?(:acts_as_archived?)
          collection = if object.new_record?
            collection.unarchived
          else
            collection.unarchived.or(collection.archived.where(collection.klass.primary_key => value))
          end
        end

        if respond_to?(:ajax?) && ajax? # effective_select
          collection = collection.where(collection.klass.primary_key => value)
        end

        collection
      end

      def assign_options_collection_methods!
        options[:input].reverse_merge!(
          if polymorphic?
            { group_method: :last, group_label_method: :first, option_key_method: :second, option_value_method: :first }
          elsif grouped?
            first = Array(options_collection.values.first).first

            string_of_strings = (
              options_collection.kind_of?(Hash) && 
              options_collection.keys.all? { |key| key.kind_of?(String) } && 
              options_collection.values.all? { |values| values.kind_of?(Array) && values.all? { |value| value.kind_of?(String) } }
            )

            if first.kind_of?(ActiveRecord::Base)
              { group_method: :last, group_label_method: :first, option_value_method: :to_s, option_key_method: :id }
            elsif string_of_strings
              { group_method: :last, group_label_method: :first, option_value_method: :to_s, option_key_method: :to_s }
            else
              { group_method: :last, group_label_method: :first, option_value_method: :first, option_key_method: :second }
            end
          elsif options_collection.first.kind_of?(Array)
            { label_method: :first, value_method: :second }
          elsif options_collection.first.kind_of?(ActiveRecord::Base)
            { label_method: :to_s, value_method: :id }
          else
            { label_method: :to_s, value_method: :to_s }
          end
        )
      end

      def polymorphic_type_method
        name.to_s.sub('_id', '') + '_type'
      end

      def polymorphic_id_method
        name.to_s.sub('_id', '') + '_id'
      end

      def polymorphic_value
        return nil unless polymorphic?
        "#{value.class.model_name}_#{value.id}" if value
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
