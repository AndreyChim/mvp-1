module NavigationHelper
    def navigtion_component
         render Educhain::Navigation::Component.new(
            logo_path: "educhain/view_components/logo/educhain.svg",
            items: [
              {
                key: "user_management",
                route: users_path,
                icon: "user-line",
                position: 30,
                match_path: ->(path) { path.start_with?(users_path) }
              }
            ]
          ) 
    end
end

