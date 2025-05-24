module NavigationAccountHelper
    def navigation_account_component
      render Educhain::Navigation::Account::Component.new(
        user_label: current_user&.email,
        account_path: "#",
        logout_path: "#",
        logout_method: :delete,
      ) 
    end
end
