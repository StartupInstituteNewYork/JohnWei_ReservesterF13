module FFI
  #
  # FFI::ManagedStruct allows custom garbage-collection of your FFI::Structs.
  #
  # The typical use case would be when interacting with a library
  # that has a nontrivial memory management design, such as a linked
  # list or a binary tree.
  #
  # When the {Struct} instance is garbage collected, FFI::ManagedStruct will
  # invoke the class's release() method during object finalization.
  #
  # @example Example usage:
  #  module MyLibrary
  #    ffi_lib "libmylibrary"
  #    attach_function :new_dlist, [], :pointer
  #    attach_function :destroy_dlist, [:pointer], :void
  #  end
  #  
  #  class DoublyLinkedList < FFI::ManagedStruct
  #    @@@
  #    struct do |s|
  #      s.name 'struct dlist'
  #      s.include 'dlist.h'
  #      s.field :head, :pointer
  #      s.field :tail, :pointer
  #    end
  #    @@@
  #
  #    def self.release ptr
  #      MyLibrary.destroy_dlist(ptr)
  #    end
  #  end
  #
  #  begin
  #    ptr = DoublyLinkedList.new(MyLibrary.new_dlist)
  #    #  do something with the list
  #  end
  #  # struct is out of scope, and will be GC'd using DoublyLinkedList#release
  #
  #
  class ManagedStruct < FFI::Struct

    # @overload initialize(pointer)
    #  @param [Pointer] pointer
    #  Create a new ManagedStruct which will invoke the class method #release on 
    # @overload initialize
    # A new instance of FFI::ManagedStruct.
    def initialize(pointer=nil)
      raise NoMethodError, "release() not implemented for class #{self}" unless self.class.respond_to? :release
      raise ArgumentError, "Must supply a pointer to memory for the Struct" unless pointer
      super AutoPointer.new(pointer, self.class.method(:release))
    end

  end
end
