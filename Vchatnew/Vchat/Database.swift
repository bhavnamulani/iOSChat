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

    // Use DatabaseMigrator to setup the database
    var migrator = DatabaseMigrator()
    
    migrator.registerMigration("msgDb") { db in

        // Create a table
        try db.create(table: "Msgs_Table") { t in
            // An integer primary key auto-generates unique IDs
            t.column("COL_MSG_BODY", .text).primaryKey()
            
            t.column("COL_FROM_USER", .text).notNull()
            
            t.column("COL_TO_USER", .text).notNull()
            
            t.column("COL_READ", .boolean).notNull()
            
            t.column("COL_SENT_BY", .text).notNull()
        }
        print("Message Table Create")
        
        // Create a table
        try db.create(table: "Users_Table") { t in
            // An integer primary key auto-generates unique IDs
            t.column("COL_NAME", .text).primaryKey()
            
            t.column("COL_USERNAME", .text).notNull()
            
            t.column("COL_EMAIL", .text).notNull()
            
            t.column("COL_LAST_MESSAGE_RECEIVED", .text).notNull()
            
            t.column("COL_UNREAD_MSG_COUNT", .integer).notNull()
        }
        print("User Table Create")
    }
    
    try migrator.migrate(dbQueue)
    print("Tables Already Created")
}

func insertIntoUserTable(userDo:UsersDo){
            try! dbQueue.inDatabase { db in
                try db.execute(
                    "INSERT INTO Users_Table (COL_NAME, COL_USERNAME, COL_EMAIL, COL_LAST_MESSAGE_RECEIVED, COL_UNREAD_MSG_COUNT) VALUES (?, ?,?,?,?)",
                    arguments: [userDo.name, userDo.username, userDo.email, userDo.lastMessageReceived, userDo.unReadMsgCount])
                _ = db.lastInsertedRowID
                print ("Insert_Users>>",userDo.name!)
            }
        }
        
        
func insertIntoMsgTable(messagesDo:MessagesDo){
            try! dbQueue.inDatabase { db in
                try db.execute(
                    "INSERT INTO Msgs_Table (COL_MSG_BODY, COL_FROM_USER, COL_TO_USER, COL_READ, COL_SENT_BY) VALUES (?, ?,?,?,?)",
                    arguments: [messagesDo.msgText, messagesDo.fromUser, messagesDo.toUser, messagesDo.read, messagesDo.sentBy as? DatabaseValueConvertible])
                _ = db.lastInsertedRowID
                print ("Insert_Msgs>>",messagesDo.msgText!)
            }
        }

