class Tree
  attr_reader :root, :degree, :size

  def initialize(degree = 1)
    @degree = degree
    @root = Node.new(@degree)
    @root.leaf = true
    @size = 0
  end

  def insert(key, value = nil)
    node = @root
    if node.full?  
      @root = Node.new(@degree)
      @root.leaf = false
      @root.add_child(node)
      @root.split(@root.children.size - 1)
      #puts "After split, root = #{@root.inspect}"
      # split child(@root, 1)
      node = @root
    end
    node.insert(key, value)
    @size += 1
    return self
  end

  def dump
    @root.dump
  end

  def value_of(key)
    @root.value_of(key)
  end

  alias_method :"[]", :value_of
  alias_method :"[]=", :insert
end
