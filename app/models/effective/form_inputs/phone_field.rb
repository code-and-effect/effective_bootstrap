module Effective
  module FormInputs
    class PhoneField < Effective::FormInput

      DEFAULT_TEL_MASK = '(999) 999-9999? x99999'
      DEFAULT_CELL_MASK = '(999) 999-9999'

      def input_html_options
        { class: 'form-control effective_phone', placeholder: '(555) 555-5555', pattern: '\(\d{3}\) \d{3}-\d{4}\d?+' }
      end

      def input_js_options
        { mask: ((cell? || fax?) ? DEFAULT_CELL_MASK : DEFAULT_TEL_MASK), placeholder: '_' }
      end

      def input_group_options
        { input_group: { class: 'input-group' }, prepend: content_tag(:span, input_group_content, class: 'input-group-text') }
      end

      private

      def input_group_content
        if cell?
          'Cell'
        elsif fax?
          'Fax'
        else
          'Phone'
        end
      end

      def fax?
        return @fax unless @fax.nil?
        @fax = options.key?(:fax) ? options.delete(:fax) : name.to_s.include?('fax')
      end

      def cell?
        return @cell unless @cell.nil?
        @cell = options.key?(:cell) ? options.delete(:cell) : name.to_s.include?('cell')
      end

    end
  end
end
