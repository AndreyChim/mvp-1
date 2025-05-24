module NavigationHelper
    def navigation_component
         render Educhain::Navigation::Component.new(
            logo_path: "educhain/view_components/logo/educhain.svg",
            user_label: current_user&.email,
            items: [
              {
                key: "Users",
                route: users_path,
                icon: "user-line",
                position: 30,
                match_path: ->(path) { path.start_with?(users_path) }
              }
            ]
          ) 
    end
end

