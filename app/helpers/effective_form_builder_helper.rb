# frozen_string_literal: true

module EffectiveFormBuilderHelper
  def effective_form_with(**options, &block)
    # This allows us to call effective_form_with inside an effective_table_with and just get the fields
    return @_effective_table_builder.capture(&block) if @_effective_table_builder

    # Compute the default ID
    subject = Array(options[:model] || options[:scope]).last
    class_name = (options[:scope] || subject.class.name.parameterize.underscore)
    unique_id = options.except(:model).hash.abs

    html_id = if subject.kind_of?(Symbol)
      subject.to_s
    elsif subject.respond_to?(:persisted?) && subject.persisted?
      "edit_#{class_name}_#{subject.to_param}"
    else
      "new_#{class_name}"
    end

    options[:html] = (options[:html] || {}).merge(novalidate: true, onsubmit: 'return EffectiveForm.validate(this)')
    options[:local] = true unless options.key?(:local)

    if respond_to?(:inline_datatable?) && inline_datatable?
      options[:remote] = true
      options[:local] = false
    end

    options[:class] = [
      options[:class],
      'needs-validation',
      ('form-inline' if options[:layout] == :inline),
      ('with-errors' if subject.respond_to?(:errors) && subject.errors.present?),
      ('show-flash-success' if options[:remote] && options[:flash_success]),
      ('hide-flash-danger' if options[:remote] && options.key?(:flash_error) && !options[:flash_error])
    ].compact.join(' ')

    if options[:remote] || options[:unique_ids]
      @_effective_unique_id ||= {}

      if @_effective_unique_id.key?(unique_id)
        unique_id = unique_id + @_effective_unique_id.length
      end

      options[:unique_id] = unique_id
      html_id = "#{html_id}_#{unique_id}"

      @_effective_unique_id[unique_id] = true
    end

    if options.delete(:remote) == true
      if options[:html][:data].kind_of?(Hash)
        options[:html][:data][:remote] = true
        options[:html][:data]['data-remote-index'] = unique_id
      else
        options[:html]['data-remote'] = true
        options[:html]['data-remote-index'] = unique_id
      end
    end

    # Assign default ID
    options[:id] ||= (options[:html].delete(:id) || html_id) unless options.key?(:id)

    # Assign url if engine present
    options[:url] ||= if options[:engine] && options[:model].present?
      resource = Effective::Resource.new(options[:model])

      if subject.respond_to?(:persisted?) && subject.persisted?
        resource.action_path(:update, subject)
      elsif subject.respond_to?(:new_record?) && subject.new_record?
        resource.action_path(:create)
      end
    end

    without_error_proc do
      form_with(**options.merge(builder: Effective::FormBuilder), &block)
    end
  end

  private

  # Disables a .fields_with_errors wrapping div when
  def without_error_proc
    original = ActionView::Base.field_error_proc

    begin
      ActionView::Base.field_error_proc = proc { |input, _| input }; yield
    ensure
      ActionView::Base.field_error_proc = original
    end
  end

end
