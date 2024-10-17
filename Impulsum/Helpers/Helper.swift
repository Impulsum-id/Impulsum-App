//
//  Helper.swift
//  SharePlate
//
//  Created by robert theo on 19/08/24.
//

import Foundation
import simd

var defaultTimePickup: Date {
    var components = DateComponents()
    components.year = Calendar.current.component(.year, from: Date())
    components.month = Calendar.current.component(.month, from: Date())
    components.day = Calendar.current.component(.day, from: Date())
    components.hour  = Calendar.current.component(.hour, from: Date()) + 1
    components.minute = Calendar.current.component(.minute, from: Date())
    return Calendar.current.date(from: components) ?? .now
}

let startDate = Date(timeIntervalSinceNow: -24.0 * 3600.0)
let endDate = Date(timeIntervalSinceNow: 24.0 * 3600.0)

func computeSignedArea(_ points: [SIMD3<Float>]) -> Float {
    var area: Float = 0.0
    let n = points.count
    for i in 0..<n {
        let p1 = points[i]
        let p2 = points[(i + 1) % n]
        area += (p1.x * p2.z - p2.x * p1.z)
    }
    return area * 0.5
}

func isConvex(_ prev: SIMD3<Float>, _ curr: SIMD3<Float>, _ next: SIMD3<Float>) -> Bool {
    let d1 = SIMD2<Float>(curr.x - prev.x, curr.z - prev.z)
    let d2 = SIMD2<Float>(next.x - curr.x, next.z - curr.z)
    let cross = d1.x * d2.y - d1.y * d2.x
    return cross > 0
}

func isPointInTriangle(_ p: SIMD2<Float>, _ a: SIMD2<Float>, _ b: SIMD2<Float>, _ c: SIMD2<Float>) -> Bool {
    let v0 = c - a
    let v1 = b - a
    let v2 = p - a

    let dot00 = simd_dot(v0, v0)
    let dot01 = simd_dot(v0, v1)
    let dot02 = simd_dot(v0, v2)
    let dot11 = simd_dot(v1, v1)
    let dot12 = simd_dot(v1, v2)

    let invDenom = 1.0 / (dot00 * dot11 - dot01 * dot01)
    let u = (dot11 * dot02 - dot01 * dot12) * invDenom
    let v = (dot00 * dot12 - dot01 * dot02) * invDenom
    return (u >= 0) && (v >= 0) && (u + v <= 1)
}

func generateMesh(_ points: [SIMD3<Float>]) -> [UInt32] {
    var indices: [UInt32] = []
    var vertexIndices = Array(0..<points.count)
    let area = computeSignedArea(points)

    if area < 0 {
        // Reverse indices for counter-clockwise orientation
        vertexIndices.reverse()
    }

    var remainingVertices = vertexIndices

    while remainingVertices.count > 3 {
        var earFound = false
        let n = remainingVertices.count
        for i in 0..<n {
            let prevIndex = remainingVertices[(i - 1 + n) % n]
            let currIndex = remainingVertices[i]
            let nextIndex = remainingVertices[(i + 1) % n]

            let prevPoint = points[prevIndex]
            let currPoint = points[currIndex]
            let nextPoint = points[nextIndex]

            if isConvex(prevPoint, currPoint, nextPoint) {
                var ear = true
                for j in 0..<n {
                    if j == (i - 1 + n) % n || j == i || j == (i + 1) % n {
                        continue
                    }
                    let pIndex = remainingVertices[j]
                    let pPoint = points[pIndex]
                    if isPointInTriangle(
                        SIMD2<Float>(pPoint.x, pPoint.z),
                        SIMD2<Float>(prevPoint.x, prevPoint.z),
                        SIMD2<Float>(currPoint.x, currPoint.z),
                        SIMD2<Float>(nextPoint.x, nextPoint.z)
                    ) {
                        ear = false
                        break
                    }
                }
                if ear {
                    indices.append(UInt32(prevIndex))
                    indices.append(UInt32(nextIndex))
                    indices.append(UInt32(currIndex))
                    
                    remainingVertices.remove(at: i)
                    earFound = true
                    break
                }
            }
        }
        if !earFound {
            print("No ear found; possible degenerate polygon")
            break
        }
    }

    if remainingVertices.count == 3 {
        indices.append(UInt32(remainingVertices[0]))
        indices.append(UInt32(remainingVertices[2]))
        indices.append(UInt32(remainingVertices[1]))
    }

    return indices
}


func calculateCentroid(of points: [SIMD3<Float>]) -> SIMD3<Float> {
    let sum = points.reduce(SIMD3<Float>(0, 0, 0), +)
    return sum / Float(points.count)
}


