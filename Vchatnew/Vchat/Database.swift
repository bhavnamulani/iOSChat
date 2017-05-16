import GRDB
import UIKit

// The shared database queue
var dbQueue: DatabaseQueue!

func setupDatabase(_ application: UIApplication) throws {
    
    // Connect to the database
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
    let databasePath = documentsPath.appendingPathComponent("db.sqlite")
    dbQueue = try DatabaseQueue(path: databasePath)
    
    dbQueue.setupMemoryManagement(in: application)
    
    //Use DatabaseMigrator to setup the database
    var migrator = DatabaseMigrator()
    migrator.registerMigration("MsgDatabase") { db in
        
        // Create a table
        try db.create(table: "Messages_Table") { t in
            // An integer primary key auto-generates unique IDs
            t.column("COL_MSG_BODY", .text)
            
            t.column("COL_FROM_USER", .text)
            
            t.column("COL_TO_USER", .text)
            
            t.column("COL_READ", .boolean)
            
            t.column("COL_SENT_BY", .text)
        }
        print("Message Table Create")
        
        // Create a table
        try db.create(table: "UserList_Table") { t in
            // An integer primary key auto-generates unique IDs
            t.column("COL_NAME", .text)
            
            t.column("COL_USERNAME", .text)
            
            t.column("COL_EMAIL", .text)
            
            t.column("COL_LAST_MESSAGE_RECEIVED", .text)
            
            t.column("COL_UNREAD_MSG_COUNT", .integer)
        }
        print("User Table Create")
    }
    
    try migrator.migrate(dbQueue)
    print("Tables Already Created")
}





func insertIntoUserTable(usersDoList: Array<UsersDo>){
    try! dbQueue.inDatabase { db in
        
        for var i in 0..<usersDoList.count {
            var usersDo: UsersDo!
            print("Data in UserDoList" , usersDoList[i])
            usersDo = usersDoList[i]
            try db.execute(
                "INSERT INTO UserList_Table (COL_NAME, COL_USERNAME, COL_EMAIL, COL_LAST_MESSAGE_RECEIVED, COL_UNREAD_MSG_COUNT) VALUES (?,?,?,?,?)",
                arguments: [usersDo.name, usersDo.username, usersDo.email, usersDo.lastMessageReceived, usersDo.unReadMsgCount])
            print ("Insert_Users>>", usersDo.name!)
            
        }
        
    }
}

func getUsersFromTable() -> Array<UsersDo> {
    var usersDoList = Array<UsersDo>()
    //   var usersDo:UsersDo?
    //   var username = (SharedPref().get("username"))
    
    try! dbQueue.inDatabase { db in
        let rows = try Row.fetchCursor(db, "SELECT * FROM UserList_Table")
        while let row = try rows.next() {
            let name: String? = row.value(named: "COL_NAME")
            let username: String? = row.value(named: "COL_USERNAME")
            let email: String? = row.value(named: "COL_EMAIL")
            let lastMsgReceived: String? = row.value(named: "COL_LAST_MESSAGE_RECEIVED")
            let unReadMsgCount: String? = row.value(named: "COL_UNREAD_MSG_COUNT")
            
            print("name",name)
            print("username",username)
            print("email",email)
            print("lastMsgReceived",lastMsgReceived)
            print("unReadMsgCount",unReadMsgCount)
            
            usersDoList.append(UsersDo(json: SharedPref().get("username") as! NSDictionary))
            print("Get Users List" , usersDoList.count)
            
        }
        
        
    }
    return usersDoList
}

func insertIntoMsgTable(messagesDo:MessagesDo){
  
    
    var sentBy:String!
    
    if(messagesDo.sentBy == LGChatMessage.SentBy.Opponent)
    {
        sentBy = "LGChatMessageSentByOpponent"
    }else{
        sentBy = "LGChatMessageSentByUser";
    }
    
      print("sent by: \(sentBy)")
    
    try! dbQueue.inDatabase { db in
        try db.execute(
            "INSERT INTO Messages_Table (COL_MSG_BODY, COL_FROM_USER, COL_TO_USER, COL_READ, COL_SENT_BY) VALUES (?, ?,?,?,?)",
            arguments: [messagesDo.msgText, messagesDo.fromUser, messagesDo.toUser, messagesDo.read, sentBy])
        _ = db.lastInsertedRowID
        
        print ("Insert_Msgs>>",messagesDo.msgText!)
    }
}


func getMessagesFromTable(userID:String!) -> [LGChatMessage] {
    var msgsDoList = [LGChatMessage]()
    
    try! dbQueue.inDatabase { db in
        let rows = try Row.fetchCursor(db, "SELECT * FROM Messages_Table WHERE COL_FROM_USER = ? OR COL_TO_USER = ?", arguments: [userID, userID])
        while let row = try rows.next() {
        
            let msgBody: String? = row.value(named: "COL_MSG_BODY")
            let fromUser: String? = row.value(named: "COL_FROM_USER")
            let toUser: String? = row.value(named: "COL_TO_USER")
            let read: String? = row.value(named: "COL_READ")
            let sentBy: String? = row.value(named: "COL_SENT_BY")
            
            
            let msgsDo = LGChatMessage(content:msgBody!,sentByString:sentBy!)
            
            print("msgBody",msgBody)
            print("fromUser",fromUser)
            print("toUser",toUser)
            print("read",read)
            print("sentBy",sentBy)
            
            msgsDoList.append(msgsDo)
            print("GetMessages: ",msgsDoList.count)
        }
    }
    
    return msgsDoList
}
