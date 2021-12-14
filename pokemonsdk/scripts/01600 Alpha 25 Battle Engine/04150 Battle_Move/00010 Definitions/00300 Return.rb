module Battle
  class Move
    class Return < Basic
      private

      def real_base_power(user, target)
        power = (user.loyalty / 2.5).clamp(1, 255)
        log_data("Power of Return: #{power}")
        return power
      end
    end
    Move.register(:s_return, Return)
  end
end
