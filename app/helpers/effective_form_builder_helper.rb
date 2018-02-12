module EffectiveFormBuilderHelper
  def effective_form_with(**options, &block)

    if options[:layout] == :inline
      options[:class] = [options[:class], 'form-inline'].compact.join(' ')
    end

    if options[:model].respond_to?(:errors)
      options[:class] = [options[:class], 'needs-validation'].compact.join(' ')
    end

    if options[:model].respond_to?(:errors) && options[:model].errors.present?
      options[:class] = [options[:class], 'was-validated'].compact.join(' ')
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
