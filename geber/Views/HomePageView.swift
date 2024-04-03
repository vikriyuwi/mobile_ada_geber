//
//  HomePage.swift
//  geber
//
//  Created by win win on 28/03/24.
//

import SwiftUI
import TipKit
import SwiftData

struct HomePage: View {
    @StateObject var beaconManager = IBeaconManager()
    
    @State var locationDetected = 0
    @State public var isSent:Bool = false
    
    @State var timer:Timer?
    @State var timeRemaining:TimeInterval = 10
    
    var body: some View {
        Color
            .background
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    BackgroundImage(location: $beaconManager.minor )
                    ActionArea(location: $beaconManager.minor, isSent: $isSent, timer: $timer, timeRemaining: $timeRemaining)
                }.frame(maxHeight: .infinity)
            );
    }
}

struct BackgroundImage: View {
    @Binding var location:Int
    var body: some View {
        VStack{
            switch location {
            case 0:
                Image("MapLocation1").resizable().scaledToFit()
            case 1:
                Image("MapLocation2").resizable().scaledToFit()
            case 2:
                Image("MapLocation3").resizable().scaledToFit()
            default:
                Image("MapNone").resizable().scaledToFit()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(0)
    }
    
    func changeImageTo(location: Int) {
        
    }
}

struct ActionArea: View {
    @Binding var location:Int
    @Query private var tips: [Tip]
    @Binding var isSent:Bool
    
    @Binding var timer:Timer?
    @Binding var timeRemaining:TimeInterval
    
    var body: some View{
        ScrollView{
            VStack {
                HStack {
                    VStack{
                        if isSent == true {
                            HelpConfirmation(color: "success", title: "Request is sent", iconName: "checkmark.circle.fill")
                            Countdown(isSent: $isSent, timeRemaining: $timeRemaining)
                            HelpDescription(desc: "Your request is sent. Wait for 1 minute before sending another request")
                            HStack{
                                VStack{
                                    Text("Don't forget to say thanks ❤️")
                                        .foregroundStyle(.disabled)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            Location(location: $location)
                            if ([0,1,2].contains(location)) {
                                HelpDescription(desc: "Slide the button below to send request for help")
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        SlideBackground()
                                        Slide(isSent: $isSent, location: $location, timer: $timer, timeRemaining: $timeRemaining, maxWidth: (geometry.size.width))
                                    }
                                }
                                .frame(height: 62)
                            } else {
                                HelpDescription(desc: "Try to move around and make sure you are in parking lot area")
                            }
                        }
                    }
                    .padding(26)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.bodyLight)
                    .foregroundColor(.body)
                    .cornerRadius(36)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.horizontal,20)
    }
}

struct Location: View{
    @Binding var location:Int
    @State var loc:String = "Unknown"
    
    var body: some View{
        HStack{
            [0,1,2].contains(location) ? Image(systemName: "mappin.circle.fill")
                .foregroundColor(.success).font(.largeTitle) : Image(systemName: "mappin.circle.fill")
                .foregroundColor(.disabled).font(.largeTitle)
            VStack{
                HStack{
                    Text(loc)
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .onChange(of: location) { () in
                            updateLocation()
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth:.infinity, alignment: .topLeading)
    }
    
    func updateLocation() {
        switch location {
        case 0:
            loc = "A01-A03"
        case 1:
            loc = "A04-A06"
        case 2:
            loc = "A07-A09"
        default:
            loc = "Unknown"
        }
    }
}

struct Countdown: View {
    @Binding var isSent:Bool
    @Binding var timeRemaining:TimeInterval
    
    var body: some View {
        HStack {
            VStack {
                Text(formatedTime())
                    .font(.largeTitle.bold())
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(20)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(.backgroundSecondary)
        .cornerRadius(20)
        .padding(.bottom, 10)
    }
    
    private func formatedTime() -> String {
        let minute = Int(timeRemaining)/60
        let second = Int(timeRemaining)%60
        return String(format: "%02d : %02d", minute,second)
    }
}

struct HelpConfirmation: View {
    @State var color:String
    @State var title:String
    @State var iconName:String
    var body: some View {
        HStack{
            Image(systemName: iconName)
                .foregroundColor(color == "success" ? .success : .danger).font(.largeTitle)
            VStack{
                HStack{
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth:.infinity, alignment: .topLeading)
    }
}

struct HelpDescription: View {
    @State var desc:String
    var body: some View {
        HStack{
            Text(desc)
        }
        .padding(.bottom,10)
        .padding(.top, 4)
    }
}

struct Slide: View{
    @StateObject var redisPubSub = RedisPubSub()
    
    @Binding var isSent: Bool
    @Binding var location: Int
    
    @Binding var timer:Timer?
    @Binding var timeRemaining:TimeInterval
    
    let maxWidth: CGFloat
    
    private let minWidth = CGFloat(62)
    @State private var width = CGFloat(62)
    
    var body: some View{
        RoundedRectangle(cornerRadius: 31)
            .fill(.success)
            .frame(width: width)
            .overlay(
                ZStack(alignment: .center) {
                    image(name: "checkmark", isShown: isSent)
                    image(name: "arrow.right", isShown: !isSent)
                },
                alignment: .center
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width > 0 {
                            width = min(max(value.translation.width + minWidth, minWidth), maxWidth)
                        }
                    }
                    .onEnded { value in
                        //                        guard isSent == true else { return }
                        if width < maxWidth {
                            width = minWidth
                            UINotificationFeedbackGenerator().notificationOccurred(.warning)
                        } else {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            redisPubSub.getHelp(minor: location)
                            setTimer()
                        }
                    }
            )
    }
    
    private func setTimer() {
        withAnimation(.spring().delay(0.5)){
            isSent = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    redisPubSub.expireHelp(key: redisPubSub.current_key_event)
                    stopTimer()
                }
            }
        }
    }
    
    private func stopTimer() {
        withAnimation(.spring()){
            isSent = false
            timer?.invalidate()
            timeRemaining = 10
        }
    }
    
    private func image(name: String, isShown: Bool) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .regular, design: .rounded))
            .foregroundColor(.body)
            .frame(width: 42, height: 42)
            .background(RoundedRectangle(cornerRadius: 21).fill(.success))
            .padding(4)
            .opacity(isShown ? 1 : 0)
            .scaleEffect(isShown ? 1 : 0.01)
    }
}

struct BaseButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.default, value: configuration.isPressed)
    }
    
}

struct SlideBackground: View {
    var body: some View {
        ZStack(alignment: .leading)  {
            RoundedRectangle(cornerRadius: 31)
                .fill(.body)
            
            Text("SLIDE TO REQUEST")
                .font(.footnote)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.leading,62)
        }
    }
    
}

struct GeberTip: View{
    var body: some View{
        HStack {
            VStack{
                HStack{
                    Image(systemName: "warninglight")
                        .rotationEffect(Angle(degrees: 180))
                    VStack{
                        Text("Try to move around")
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
            }
            .padding(26)
        }
        .background(.tipsBackground)
        .cornerRadius(20)
    }
}

func Ticket()->some View{
    HStack(
        spacing: 0
    ){
        VStack{
            
        }
        .frame(maxHeight: .infinity)
        .frame(width: 26)
        .padding(26)
        .background(Color.accent)
        .cornerRadius(26)
        VStack{
            Text("\nLocation undetected\n")
        }
        .frame(maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
        .frame(maxWidth: .infinity)
        .padding(26)
        .background(Color.accent)
        .cornerRadius(26)
        
    }
    .fixedSize(horizontal: false, vertical: true)
    .frame(width: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
    .padding([.horizontal],42)
    .padding([.bottom], -26)
    .offset(y: -42)
}

func BottomButton()->some View{
    VStack{
        Button{
            
        } label: {
            HStack{
                Text("SCAN LOCATION")
                    .padding(26)
                    .font(.system(size: 16, weight:.heavy))
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .foregroundColor(.body)
            .background(Color.accent)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            .cornerRadius(26)
        }
    }
    .frame(alignment: .topLeading)
    .padding(.horizontal,42)
}

#Preview {
    HomePage()
}
