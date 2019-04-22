module EffectiveFormBuilderHelper
  def effective_form_with(**options, &block)

    # Compute the default ID
    subject = Array(options[:scope] || options[:model]).last
    class_name = subject.class.name.underscore

    html_id = if subject.kind_of?(Symbol)
      subject.to_s
    elsif subject.respond_to?(:persisted?) && subject.persisted?
      "edit_#{class_name}_#{subject.to_param}"
    else
      "new_#{class_name}"
    end

    options[:class] = [options[:class], 'needs-validation', ('form-inline' if options[:layout] == :inline), ('with-errors' if subject.respond_to?(:errors) && subject.errors.present?)].compact.join(' ')
    options[:html] = (options[:html] || {}).merge(novalidate: true, onsubmit: 'return EffectiveForm.validate(this);')

    remote_index = options.except(:model).hash.abs

    if options.delete(:remote) == true
      @_effective_remote_index ||= 0

      if options[:html][:data].kind_of?(Hash)
        options[:html][:data][:remote] = true
        options[:html][:data]['data-remote-index'] = remote_index
      else
        options[:html]['data-remote'] = true
        options[:html]['data-remote-index'] = remote_index
      end

      html_id = "#{html_id}_#{remote_index}"
    end

    # Assign default ID
    options[:id] ||= (options[:html].delete(:id) || html_id) unless options.key?(:id)

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
