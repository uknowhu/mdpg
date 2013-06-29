module Wnp

  class UserGroups < Struct.new(:env, :user)

    def group_ids_and_names_sorted_by_name
      group_ids_and_names.sort{|a,b| a[1] <=> b[1]}
    end

    private

      def group_ids_and_names
        groups.map{|x| [x.id, x.name]}
      end

      def groups
        user.get_group_ids().map{|x| group = Group.new(env, x); group.load; group}
      end

  end

end
