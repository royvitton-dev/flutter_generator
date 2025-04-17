sequenceDiagram
  participant MyApp
  participant ColorScheme
  participant MyHomePage
  participant _MyHomePageState
  participant Theme
par build()
  MyApp->>MyApp: MaterialApp()
  MyApp->>MyApp: ThemeData()
  MyApp->>ColorScheme: fromSeed()
end
par createState()
  MyHomePage->>MyHomePage: _MyHomePageState()
end
par _incrementCounter()
  _MyHomePageState->>_MyHomePageState: setState()
end
par build()
  _MyHomePageState->>_MyHomePageState: Scaffold()
  _MyHomePageState->>_MyHomePageState: AppBar()
  _MyHomePageState->>Theme: of()
  _MyHomePageState->>_MyHomePageState: Text()
  _MyHomePageState->>_MyHomePageState: Center()
  _MyHomePageState->>_MyHomePageState: Column()
  _MyHomePageState->>_MyHomePageState: Text()
  _MyHomePageState->>Theme: of()
  _MyHomePageState->>_MyHomePageState: FloatingActionButton()
end
