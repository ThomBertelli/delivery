
admin = User.find_by(email: "admin@example.com")

if !admin

  admin = User.new(
    email: "admin@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :admin
  )

  admin.save!
end

["Orange Curry","Belly King"].each do |store|
  user = User.new(
    email: "#{store.split.map { |s| s.downcase}.join(".")}@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :seller

  )
  user.save!
  Store.find_or_create_by!(name: store, user: user)
end

[

"Massaman Curry",

"Risotto with Seafood",

"Tuna Sashimi",

"Fish and Chips",

"Pasta Carbonara"

].each do |dish|

  store = Store.find_by(name: "Orange Curry")

  Product.find_or_create_by!( title: dish, store: store )

end


[

"Mushroom Risotto",

"Caesar Salad",

"Mushroom Risotto",

"Tuna Sashimi",

"Chicken Milanese"

].each do |dish|

store = Store.find_by(name: "Belly King")

Product.find_or_create_by!(title: dish, store: store)

end


["Aracelis Weissnat", "Pasquale Wisozk"].each do |buyer|
  email = buyer.split.map { |s| s.downcase }.join(".")
  user = User.find_by(email: email)
  if !user
    user = User.new(
    email: "#{email}@example.com",
    password: "123456",
    password_confirmation: "123456",
    role: :buyer
    )
    user.save!
  end
end
