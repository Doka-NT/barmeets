//
//  AppDelegate.swift
//  barmeets
//
//  Created by Артем Сошников on 18.05.2024.
//

import Cocoa
import EventKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "1.circle", accessibilityDescription: "1")
        }
        
        let menu = NSMenu()
        
        loadCalendar(menu: menu)
        
        statusItem.menu = menu
    }
    
    func checkUrlInString(inputString: String) -> String? {
        let regexPattern = "https://telemost\\.yandex\\.ru/j/\\d+"
        let inputString = "Ссылка на трансляцию: https://telemost.yandex.ru/j/27332108706473. Еще ссылка: https://telemost.yandex.ru/j/54321"

        if let regex = try? NSRegularExpression(pattern: regexPattern, options: []) {
            let range = NSRange(inputString.startIndex..<inputString.endIndex, in: inputString)
            let matches = regex.matches(in: inputString, options: [], range: range)

            for match in matches {
                let matchRange = match.range
                if let range = Range(matchRange, in: inputString) {
                    print("Найдено вхождение: \(inputString[range])") // Вывод вхождения
                    
                    return "\(inputString[range])"
                }
            }
        } else {
            print("Ошибка в регулярном выражении")
        }

        return nil
    }
    
    func loadCalendar(menu: NSMenu) {
        let eventStore = EKEventStore()
                
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: Date())
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
                let events = eventStore.events(matching: predicate)
                
                for event in events {
                    print("Title: \(event.title), Start Date: \(event.startDate), End Date: \(event.endDate)")
                    // Другие свойства события могут быть доступны здесь
                    
                    var selectorNull = #selector(self.onClickDoNothing)
                    var selectorOpen = #selector(self.onClickOpenMeet)
                    
                    var meetUrl = self.checkUrlInString(inputString: event.description)
                    
                    var selector: Selector
                    var callIcon = ""
                    if (meetUrl == nil) {
                        selector = selectorNull
                    } else {
                        selector = selectorOpen
                        callIcon = " \u{1F4DE}"
                    }
                    
                    var menuItemTitle = "\(event.startDate.formatted()) \(event.title!)\(callIcon)"
                    var menuItem = NSMenuItem(title: menuItemTitle, action: selector, keyEquivalent: "")
                    menuItem.representedObject = meetUrl
                    
                    menu.addItem(menuItem)
                    
                }
            } else {
                if let error = error {
                    print("Ошибка получения доступа к календарям: \(error.localizedDescription)")
                }
            }
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func onHelloClick() {
        
    }
    
    @objc func onClickDoNothing() {
        
    }
    
    @objc func onClickOpenMeet(_ sender:NSMenuItem) {
        if let urlString = sender.representedObject as? String, let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }

    }
}

