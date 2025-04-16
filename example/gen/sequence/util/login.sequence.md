sequenceDiagram
  participant Login
  participant user
  participant Auth
par toJson()
  Login->>user: toJson()
end
par getUserType()
  alt 
Login <<-->> Login : switch(user.userType)
    else admin
    else staff
    else member
  Login->>user: toJson()
    else default
  Login->>user: isAdmin()
Login <<-->> Login : switch end
  end
end
par checkUser()
  alt 
Login <<-->> Login : switch(name)
    else 'admin'
    else 'staff'
    else 'member'
    else default
Login <<-->> Login : switch end
  end
  alt
  Login->>user: isAdmin()
  end
  alt
  else
  Login->>Auth: getToken()
  end
end
