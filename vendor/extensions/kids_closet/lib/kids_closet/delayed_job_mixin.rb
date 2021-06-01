module KidsCloset
  module DelayedJobMixin


      def self.included(base)

          def enqueue_new(*args)
            object = args.shift
            unless object.respond_to?(:perform)
              raise ArgumentError, 'Cannot enqueue items which do not respond to perform'
            end
      
            priority = args.first || 0
            run_at   = args[1]
            email_id = args.length > 3 ? args[2] : nil
            self.create(:payload_object => object, :priority => priority.to_i, :run_at => run_at, :kids_email_id => email_id)
          end
        end
  end
end
