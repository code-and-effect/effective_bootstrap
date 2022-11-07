# frozen_string_literal: true

module Effective
  module FormInputs
    class ArticleEditor < Effective::FormInput

      # https://imperavi.com/article/docs/settings/
      def self.defaults
        {
           # This is overridden by the active_storage() method below
          active_storage: nil,

          # This is overridden by the css() method below
          css: ['/assets/article_editor/arx-frame.min.css'],

          # This is overridden by the custom_css() method below
          custom: {
            css: ['application.css', '/assets/effective_bootstrap_article_editor.css']
          },

          # The rest of these are just normal Hash options
          align: {
            'left': 'text-left',
            'center': 'text-center',
            'right': 'text-right',
            'justify': false
          },
          cellcolors: {
            'primary': { title: 'Primary', classname: 'table-primary' },
            'secondary': { title: 'Secondary', classname: 'table-secondary' },
            'active': { title: 'Active', classname: 'table-active' },
            'success': { title: 'Success', classname: 'table-success' },
            'danger': { title: 'Danger', classname: 'table-danger' },
            'warning': { title: 'Warning', classname: 'table-warning' },
            'info': { title: 'Info', classname: 'table-info' },
            'light': { title: 'Light', classname: 'table-light' },
            'dark': { title: 'Dark', classname: 'table-dark' }
          },
          classes: { table: 'table' },
          editor: {
            csscache: true,  # Do not add ?=timestamp to css requests
            https: true      # Embed links use https
          },
          embed: { script: false }, # do not strip out script tag from embeds
          filelink: nil,
          format: ['p', 'h2', 'h3', 'h4', 'h5', 'ul', 'ol'],
          grid: {
            classname: 'row',
            columns: 12,
            gutter: '1px',
            offset: {
              left: '15px',
              right: '15px',
            },
            patterns: {
              '6|6': 'col-md-6|col-md-6',
              '4|4|4': 'col-md-4|col-md-4|col-md-4',
              '3|3|3|3': 'col-md-3|col-md-3|col-md-3|col-md-3',
              '2|2|2|2|2|2': 'col-md-2|col-md-2|col-md-2|col-md-2|col-md-2|col-md-2',
              '3|6|3': 'col-md-3|col-md-6|col-md-3',
              '2|8|2': 'col-md-2|col-md-8|col-md-2',
              '5|7': 'col-md-5|col-md-7',
              '7|5': 'col-md-7|col-md-5',
              '4|8': 'col-md-4|col-md-8',
              '8|4': 'col-md-8|col-md-4',
              '3|9': 'col-md-3|col-md-9',
              '9|3': 'col-md-9|col-md-3',
              '2|10': 'col-md-2|col-md-10',
              '10|2': 'col-md-10|col-md-2',
              '12': 'col-md-12'
            }
          },
          layer: false, # the layer button is confusing for the layperson
          link: { size: 500 }, # truncate after this length
          makebutton: {
            items: {
              primary: {
                title: 'Primary',
                params: { classname: 'btn btn-primary' }
              },
              secondary: {
                title: 'Secondary',
                params: { classname: 'btn btn-secondary' }
              },
              danger: {
                title: 'Danger',
                params: { classname: 'btn btn-danger' }
              },
              primary_large: {
                title: 'Primary (large)',
                params: { classname: 'btn btn-lg btn-primary' }
              },
              secondary_large: {
                title: 'Secondary (large)',
                params: { classname: 'btn btn-lg btn-secondary' }
              },
              danger_large: {
                title: 'Danger (large)',
                params: { classname: 'btn btn-lg btn-danger' }
              }
            }
          },
          outset: false, # tricky to design around
          plugins: ['blockcode', 'carousel', 'cellcolor', 'collapse', 'filelink', 'imageposition', 'imageresize', 'inlineformat', 'listitem', 'makebutton', 'removeformat', 'reorder', 'style'],
          quote: {
            template: '<blockquote class="blockquote text-center"><p class="mb-0"><strong>A well-known quote, contained in a blockquote element.</strong></p></blockquote>'
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

      def default_mode
        self.class.defaults
      end

      def restricted_mode
        self.class.defaults.merge(
          code: false,
          editor: { csscache: true, https: true, drop: false },
          embed: false,
          image: false,
          plugins: ['blockcode', 'cellcolor', 'inlineformat', 'listitem', 'removeformat', 'reorder', 'style']
        )
      end

      def content
        (defined?(ActionText::RichText) && value.kind_of?(ActionText::RichText)) ? value.body&.to_html : value
      end

      def build_input(&block)
        @builder.super_text_area(name, options[:input].merge(value: content))
      end

      def input_html_options
        { class: 'effective_article_editor form-control', id: unique_id, autocomplete: 'off' }
      end

      def input_js_options
        case mode
        when :default, :admin
          default_mode.merge(active_storage: active_storage, css: css, custom: { css: custom_css })
        when :restricted
          restricted_mode.merge(active_storage: false, css: css, custom: { css: custom_css })
        else
          raise("unexpected mode: #{mode}. Try :default or :restricted")
        end
      end

      def css
        if @template.respond_to?(:asset_pack_path)
          [@template.asset_pack_path('article_editor/arx-frame.min.css')]
        elsif @template.respond_to?(:asset_path)
          [@template.asset_path('article_editor/arx-frame.min.css')]
        else
          ['/assets/article_editor/arx-frame.min.css']
        end
      end

      def custom_css
        if @template.respond_to?(:asset_pack_path)
          [
            @template.asset_pack_path('application.css'),
            @template.asset_pack_path('effective_bootstrap_article_editor.css')
          ]
        elsif @template.respond_to?(:asset_path)
          [
            @template.asset_path('application.css'),
            @template.asset_path('effective_bootstrap_article_editor.css')
          ]
        else
          [
            '/assets/application.css',
            '/assets/effective_bootstrap_article_editor.css'
          ]
        end
      end

      def active_storage
        return @active_storage unless @active_storage.nil?

        @active_storage = if options.key?(:active_storage)
          options.delete(:active_storage)
        else
          defined?(ActiveStorage).present?
        end
      end

      def mode
        return @mode unless @mode.nil?

        @mode = if options.key?(:mode)
          options.delete(:mode)
        else
          select_mode()
        end
      end

      def select_mode
        EffectiveResources.authorized?(@template, :admin, :effective_article_editor) ? :default : :restricted
      end

    end
  end
end
