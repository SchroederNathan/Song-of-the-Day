//
//  CustomDialog.swift
//  SongOfTheDay
//
//  Created by Nathan Schroeder on 2023-11-22.
//

import UIKit

class CustomAnimation: UIView {
    
    override func draw(_ rect: CGRect) {
        
        //draw the circle that represents the view centered in the screen
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: round((bounds.width) / 2), y: round((bounds.height) / 2)), radius: CGFloat(50), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        
        //set the custom accent colour as the fill
        UIColor(named: "CardColors")?.withAlphaComponent(0.9).setFill()
        
        //fill the path
        circlePath.fill()
        
        //get the checkmark image
        guard let image = UIImage(systemName: "checkmark")?.withTintColor(UIColor(named: "AccentColor")!) else { return }
        
        //draw the checkmark image at a specific location
        image.draw(in: CGRect(x: center.x - 25, y: center.y - 25, width: 50, height: 50))
    }
    
    //method for animating the display of our custom dialog
    func showDialog(){
        //set it to be transparent
        alpha = 0
        
        //animate with a spring animation
        UIView.animate(withDuration: 1.0, delay: 0,usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            //go from transparent to fully opaque
            self.alpha = 1
            //increase the size to 1.5X
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            //after a 1.5 second delay, hide the view once more
            UIView.animate(withDuration: 1.0, delay: 1.5, animations: {
                self.alpha = 0
                self.transform = .identity
            })
        })
    }
}


