module UsersHelper
    def user_tab_component(text:, **options)
      render Educhain::Tab::Component.new(
        text: text,
        tag: :div,
        size: :m,
        **options
      )
    end
end