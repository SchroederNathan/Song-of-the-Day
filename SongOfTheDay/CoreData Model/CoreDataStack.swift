//
//  CoreDataStack.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-01.
//

import Foundation
import CoreData

class CoreDataStack{
    private let modelName: String
    static let coreDataStack = CoreDataStack(modelName: "JournalModel")
    
    init(modelName: String){
        self.modelName = modelName
    }
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        
        container.loadPersistentStores{
            storeDescription, error in
            if let error = error {
                fatalError("Unresolved error loading the persistent container - \(error.localizedDescription)")
            }
        }
        
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.container.viewContext
    }()
    
    func saveContext(){
        guard managedContext.hasChanges else { return }
        
        do{
            try managedContext.save()
        } catch {
            fatalError("Unresolved error when trying to save - \(error.localizedDescription)")
        }
    }
}
