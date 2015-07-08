//
//  FBClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

protocol FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat
    
}

class FBClusteringManager : NSObject {
    
    var delegate:FBClusteringManagerDelegate? = nil
    
    var tree:FBQuadTree? = nil
    
    var lock:NSRecursiveLock = NSRecursiveLock()
    
        
    override init(){
        super.init()
    }
    
    init(annotations: [MKAnnotation]){
        super.init()
        addAnnotations(annotations)
    }
    
    func setAnnotations(annotations:[MKAnnotation]){
        tree = nil
        addAnnotations(annotations)
    }
    
    func addAnnotations(annotations:[MKAnnotation]){
        if tree == nil {
            tree = FBQuadTree()
        }
        
        lock.lock()
        for annotation in annotations {
            tree!.insertAnnotation(annotation)
        }
        lock.unlock()
    }
    
    func clusteredAnnotationsWithinMapRect(rect:MKMapRect, withZoomScale zoomScale:Double) -> [MKAnnotation]{
        
        
        let cellSize:CGFloat = FBClusteringManager.FBCellSizeForZoomScale(MKZoomScale(zoomScale))
        
//        if delegate?.respondsToSelector("cellSizeFactorForCoordinator:") {
//            cellSize *= delegate.cellSizeFactorForCoordinator(self)
//        }
        
        let scaleFactor:Double = zoomScale / Double(cellSize)
        
        let minX:Int = Int(floor(MKMapRectGetMinX(rect) * scaleFactor))
        let maxX:Int = Int(floor(MKMapRectGetMaxX(rect) * scaleFactor))
        let minY:Int = Int(floor(MKMapRectGetMinY(rect) * scaleFactor))
        let maxY:Int = Int(floor(MKMapRectGetMaxY(rect) * scaleFactor))

        var clusteredAnnotations = [MKAnnotation]()

        lock.lock()

        for i in minX...maxX {

            for j in minY...maxY {

                let mapPoint = MKMapPoint(x: Double(i)/scaleFactor, y: Double(j)/scaleFactor)
                
                let mapSize = MKMapSize(width: 1.0/scaleFactor, height: 1.0/scaleFactor)
                
                let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
                let mapBox:FBBoundingBox  = FBQuadTreeNode.FBBoundingBoxForMapRect(mapRect)
                
                var totalLatitude:Double = 0
                var totalLongitude:Double = 0
                
                var annotations = [MKAnnotation]()
                
                tree?.enumerateAnnotationsInBox(mapBox){ obj in
                    totalLatitude += obj.coordinate.latitude
                    totalLongitude += obj.coordinate.longitude
                    annotations.append(obj)
                }
                
                let count = annotations.count
                
                if count == 1 {
                    clusteredAnnotations += annotations
                }
                
                if count > 1 {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(count),
                        longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(count)
                    )
                    var cluster = FBAnnotationCluster()
                    cluster.coordinate = coordinate
                    cluster.annotations = annotations
                    
                    println("cluster.annotations.count:: \(cluster.annotations.count)")
                    
                    clusteredAnnotations.append(cluster)
                }

                
                
            }
           
        }
        
    
        lock.unlock()
        
        return clusteredAnnotations
    }
    
    func allAnnotations() -> [MKAnnotation] {
        
        var annotations = [MKAnnotation]()
        
        lock.lock()
        tree?.enumerateAnnotationsUsingBlock(){ obj in
            annotations.append(obj)
        }
        lock.unlock()
        
        return annotations
    }
    
    func displayAnnotations(annotations: [MKAnnotation], onMapView mapView:MKMapView){
        
        dispatch_async(dispatch_get_main_queue())  {

            var before = NSMutableSet(array: mapView.annotations)
            before.removeObject(mapView.userLocation)
            var after = NSSet(array: annotations)
            var toKeep = NSMutableSet(set: before)
            toKeep.intersectSet(after as Set<NSObject>)
            var toAdd = NSMutableSet(set: after)
            toAdd.minusSet(toKeep as Set<NSObject>)
            var toRemove = NSMutableSet(set: before)
            toRemove.minusSet(after as Set<NSObject>)
        
            mapView.addAnnotations(toAdd.allObjects)
            mapView.removeAnnotations(toRemove.allObjects)
        }
        
    }
    
    class func FBZoomScaleToZoomLevel(scale:MKZoomScale) -> Int{
        let totalTilesAtMaxZoom:Double = MKMapSizeWorld.width / 256.0
        let zoomLevelAtMaxZoom:Int = Int(log2(totalTilesAtMaxZoom))
        let floorLog2ScaleFloat = floor(log2f(Float(scale))) + 0.5
        let sum:Int = zoomLevelAtMaxZoom + Int(floorLog2ScaleFloat)
        let zoomLevel:Int = max(0, sum)
        return zoomLevel;
    }
    
    class func FBCellSizeForZoomScale(zoomScale:MKZoomScale) -> CGFloat {
        
        let zoomLevel:Int = FBClusteringManager.FBZoomScaleToZoomLevel(zoomScale)
        
        switch (zoomLevel) {
        case 13:
            return 64
        case 14:
            return 64
        case 15:
            return 64
        case 16:
            return 32
        case 17:
            return 32
        case 18:
            return 32
        case 19:
            return 16
            
        default:
            return 88
        }
        
    }
    
}