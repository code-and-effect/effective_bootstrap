module Effective
  module FormInputs
    class ArticleEditor < Effective::FormInput

      # https://imperavi.com/article/docs/settings/
      def self.defaults
        {
          active_storage: nil,
          css: '/assets/article_editor/',
          custom: {
            css: ['/assets/application.css', '/assets/effective_bootstrap_article_editor.css']
          },
          classes: {
            body: 'article-editor-body',
            table: 'table'
          },
          grid: {
            classname: 'row',
            columns: 12,
            gutter: '1px',
            offset: {
              left: '15px',
              right: '15px',
            },
            patterns: {
              '6|6': 'col-sm-6|col-sm-6',
              '4|4|4': 'col-sm-4|col-sm-4|col-sm-4',
              '3|3|3|3': 'col-sm-3|col-sm-3|col-sm-3|col-sm-3',
              '2|2|2|2|2|2': 'col-sm-2|col-sm-2|col-sm-2|col-sm-2|col-sm-2|col-sm-2',
              '3|6|3': 'col-sm-3|col-sm-6|col-sm-3',
              '2|8|2': 'col-sm-2|col-sm-8|col-sm-2',
              '5|7': 'col-sm-5|col-sm-7',
              '7|5': 'col-sm-7|col-sm-5',
              '4|8': 'col-sm-4|col-sm-8',
              '8|4': 'col-sm-8|col-sm-4',
              '3|9': 'col-sm-3|col-sm-9',
              '9|3': 'col-sm-9|col-sm-3',
              '2|10': 'col-sm-2|col-sm-10',
              '10|2': 'col-sm-10|col-sm-2',
              '12': 'col-sm-12'
            }
          },
          plugins: ['blockcode', 'imageposition', 'imageresize', 'inlineformat', 'removeformat', 'reorder', 'style'],
          quote: {
            template: '<blockquote><p></p></blockquote>'
          },
          styles: {
            table: {
              'bordered': { title: 'Bordered', classname: 'table-bordered' },
              'responsive': { title: 'Responsive', classname: 'table-responsive' },
              'small': { title: 'Small', classname: 'table-sm' },
              'striped': { title: 'Striped', classname: 'table-striped' },
            }
          }
        }
      end

      def build_input(&block)
        @builder.super_text_area(name, options[:input])
      end

      def input_html_options
        { class: 'effective_article_editor form-control', id: unique_id, autocomplete: 'off' }
      end

      def input_js_options
        self.class.defaults.merge(active_storage: active_storage)
      end

      def active_storage
        return @active_storage unless @active_storage.nil?

        @active_storage = if options.key?(:active_storage)
          options.delete(:active_storage)
        else
          defined?(ActiveStorage).present?
        end
      end

    end
  end
end
