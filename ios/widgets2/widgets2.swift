//
//  NewsWidgets.swift
//  NewsWidgets
//
//  Created by iron on 2024/1/15.
//

import WidgetKit
import SwiftUI
import Foundation

// 负责为小组件提供数据
struct Provider: TimelineProvider {

// 在首次显示小组件，没有数据时使用占位
    func placeholder(in context: Context) -> NewsArticleEntry {
//      Add some placeholder title and description, and get the current date
      NewsArticleEntry(date: Date(), value: [
        TodoItem(name:"示例待办",status:0,color: "235,85,70,1"),
        TodoItem(name:"示例待办2",status:1,color: "240,163,60,1")
      ])
    }

// 获取小组件的快照，例如在小组件库中预览时会调用
    func getSnapshot(in context: Context, completion: @escaping (NewsArticleEntry) -> ()) {
      let entry: NewsArticleEntry
      if context.isPreview{
        entry = placeholder(in: context)
      }
      else{
        print("接收参数~~~")
        //      Get the data from the user defaults to display
        let userDefaults = UserDefaults(suiteName: "group.widgetshome")
        let value = userDefaults?.string(forKey: "value") ?? "[]"
        if  let jsonStrData = value.data(using: .utf8) {
            let todolist: [TodoItem] = try! JSONDecoder().decode([TodoItem].self, from: jsonStrData)
            entry = NewsArticleEntry(date: Date(), value: todolist)
            completion(entry)
        }
      }
    }

//    这个方法来获取当前时间和（可选）未来时间的时间线的小组件数据以更新小部件。也就是说你在这个方法中设置在什么时间显示什么内容
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//      This just uses the snapshot function you defined earlier
      getSnapshot(in: context) { (entry) in
// atEnd policy tells widgetkit to request a new entry after the date has passed
        let timeline = Timeline(entries: [entry], policy: .atEnd)
                  completion(timeline)
              }
    }
}


// 小组件的数据模型
struct NewsArticleEntry: TimelineEntry {
    let date: Date
    let value: Array<TodoItem>
}


struct TodoItem: Identifiable,Decodable {
     let id = UUID()
     var name: String
     var status: Int
     var color: String
     private enum CodingKeys: String, CodingKey {
        case color
        case name
        case status
     }
 }

extension Color {
    init(hex: String) {
        let rgbaArr = hex.components(separatedBy: ",")
        let red = Double(rgbaArr[0])! / 255.0
        let green = Double(rgbaArr[1])! / 255.0
        let blue = Double(rgbaArr[2])! / 255.0
        let alpha = Double(rgbaArr[3])!

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

// 小号组件
struct SmallWidgetView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .center) {
            ForEach(entry.value.prefix(4))  { item in
               HStack(alignment:.center, content: {
                   if(item.status == 0) {
                       Image(systemName: "circle").foregroundColor(Color(hex: item.color))
                   }
                   if(item.status == 1) {
                       Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: item.color))
                   }
                   Text(item.name).font(.system(size: 16)).lineLimit(1) // 设置最大行数为1
                       .truncationMode(.tail) // 显示省略号
                   Spacer()
               })
               .padding(.top, 0.2)
               .padding(.bottom, 2)
            }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .center
            )
        
    }
}
// 中号组件
struct MediumWidgetView : View {
    var entry: Provider.Entry
    var body: some View {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
            ForEach(entry.value.prefix(8)) { item in
                HStack(alignment:.center, content: {
                    if(item.status == 0) {
                        Image(systemName: "circle").foregroundColor(Color(hex: item.color))
                    }
                    if(item.status == 1) {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(Color(hex: item.color))
                    }
                    Text(item.name).font(.system(size: 16)).lineLimit(1) // 设置最大行数为1
                        .truncationMode(.tail) // 显示省略号
                    Spacer()
                })
                .padding(.top, 0.2)
                .padding(.bottom, 2)
             }
        }
        .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 0,
              maxHeight: .infinity,
              alignment: .center
        )
        
    }
}
// 小组件的视图
struct NewsWidgetsEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family
    var body: some View {
        switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            default:
                SmallWidgetView(entry: entry)
        }
    }
}
// 小组件的配置部分
struct NewsWidgets: Widget {
    // 是这个小组件的唯一标识，可以随便填，以后当你的 App 有多个小组件，为了识别某个小组件时会用得上
    let kind: String = "widgets2"
    // 可以针对小组件做一些配置，比如名称、描述、支持的类型等等：
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NewsWidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NewsWidgetsEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("今日待办")
        .description("显示今日需要完成的事项")
        .supportedFamilies([.systemSmall, .systemMedium]) // 支持小、中、大尺寸
    }
}

