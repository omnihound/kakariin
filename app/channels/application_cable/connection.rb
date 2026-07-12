module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user
    end

    private
      # No reject_unauthorized_connection here: the public /live scoreboard
      # subscribes to court/pool/division streams with no session at all, and
      # those streams carry nothing more sensitive than what that page already
      # shows anonymously. current_user just stays nil for those connections.
      def set_current_user
        if session = Session.find_by(id: cookies.signed[:session_id])
          self.current_user = session.user
        end
      end
  end
end
