//
//  CoreDataManager.swift
//  TestCoreData
//
//  Created by Dmitry Sachkov on 16.04.2024.
//

import Foundation
import CoreData

final class CoreDataManager {
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestCoreData")
        
        let migrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                      NSInferMappingModelAutomaticallyOption: true]
        
        container.loadPersistentStores { (storeDescription, error) in
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    func fetchUserData() -> [PersonFromDataBase] {
        let fetch = NSFetchRequest<Person>(entityName: "Person")
        let context = self.persistentContainer.viewContext
        var users = [PersonFromDataBase]()
        do {
            let objects = try context.fetch(fetch)
            objects.forEach {
                let user = PersonFromDataBase(name: $0.name ?? "")
                users.append(user)
            }
        } catch {
            print(error.localizedDescription)
        }
        return users
    }
    
    func fetchRunningData(forUser user: PersonFromDataBase) -> [RunningEvent] {
        let fetchRequest: NSFetchRequest<RunningData> = RunningData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "person.name == %@", user.name)
        
        let context = self.persistentContainer.viewContext
        var runnings = [RunningEvent]()
        
        do {
            let objects = try context.fetch(fetchRequest)
            objects.forEach {
                let running = RunningEvent(name: $0.name ?? "", date: $0.date ?? Date())
                runnings.append(running)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return runnings
    }
    
    func saveUserData(_ user: PersonFromDataBase) {
        let context = self.persistentContainer.viewContext
        let fetch = NSFetchRequest<Person>.init(entityName: "Person")
        if let userData = NSEntityDescription.insertNewObject(forEntityName: "Person",
                                                              into: context) as? Person {
            userData.name = user.name
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveRunningData(_ data: RunningEvent, forUser user: PersonFromDataBase) {
        let context = self.persistentContainer.viewContext
        let personFetchRequest = NSFetchRequest<Person>.init(entityName: "Person")
        personFetchRequest.predicate = NSPredicate(format: "name == %@", user.name)
        
        do {
            if let person = try context.fetch(personFetchRequest).first {
                if let running = NSEntityDescription.insertNewObject(forEntityName: "RunningData", into: context) as? RunningData {
                    running.name = data.name
                    running.date = data.date
                    running.person = person
                    
                    try context.save()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

}

struct PersonFromDataBase {
    let name: String
}

struct RunningEvent {
    var name: String
    let date: Date
}
