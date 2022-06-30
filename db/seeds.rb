# config: utf-8

User.create!(name: "管理者",
        email: "sample@email.com",
        employee_number: 101,
        uid: 101,
        password: "password",
        password_confirmation: "password",
        admin: true)
        
User.create!(name: "上長A",
            email: "sampleA@email.com",
            employee_number: 102,
            uid: 102,
            password: "password",
            password_confirmation: "password",
            department: "総務",
            superior: true)
            
User.create!(name: "上長B",
            email: "sampleB@email.com",
            employee_number: 103,
            uid: 103,
            password: "password",
            password_confirmation: "password",
            department: "総務",
            superior: true)

15.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
         email: email,
         employee_number: n+1,
         uid: n+1,
         password: password,
         password_confirmation: password)
end
