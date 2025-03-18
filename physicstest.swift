import Foundation

struct Vector {
    
    var x: Float
    var y: Float
    
    init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    func add(_ other: Vector) -> Vector {
        return Vector(self.x + other.x, self.y + other.y)
    }
    
    func scale(_ other: Float) -> Vector {
        return Vector(self.x * other, self.y * other)
    }
    
    func toString() -> String {
        return "Vector(\(self.x), \(self.x))"
    }
    
}

class Particle {
    
    let displayChar: String
    let size: Int
    var position: Vector
    var velocity: Vector
    var acceleration: Vector
    
    init(displayChar: String, size: Int, position: Vector) {
        self.displayChar = displayChar
        self.size = size
        
        self.position = position
        self.velocity = Vector(0, 0)
        self.acceleration = Vector(0, 0)
    }
    
}

class Display {
    
    let width: Int
    let height: Int
    let emptyChar: String
    
    var particles: [Particle] = []
    var content: [[String]]
    
    init(width: Int, height: Int, emptyChar: String) {
        self.width = width
        self.height = height
        self.emptyChar = emptyChar
        
        self.content = Array(repeating: Array(repeating: self.emptyChar, count: self.width), count: self.height)
    }
    
    func update() {
        for i in 0..<self.particles.count {
            var particle = self.particles[i]
            self.drawParticle(particle: particle, char: self.emptyChar)
            
            if Int(particle.position.y) + particle.size != 0 {
                particle.velocity = particle.velocity.add(particle.acceleration)
            }
            particle.position = particle.position.add(particle.velocity)
            particle.acceleration = Vector(0, 0)
            
            if abs(particle.velocity.x) < Constants.velocityThreshold { particle.velocity.x = 0 }
            if abs(particle.velocity.y) < Constants.velocityThreshold { particle.velocity.y = 0 }
            
            if Int(particle.position.y) + particle.size > self.height - 1 {
                particle.position.y = Float(self.height - 1 - particle.size)
                particle.velocity.y *= -1 * Constants.velocityDampening
            } else if Int(particle.position.y) - particle.size < 0 {
                particle.position.y = Float(particle.size)
                particle.velocity.y *= -1 * Constants.velocityDampening
            }

            if Int(particle.position.x) + particle.size > self.width - 1 {
                particle.position.x = Float(self.width - 1 - particle.size)
                particle.velocity.x *= -1 * Constants.velocityDampening
            } else if Int(particle.position.x) - particle.size < 0 {
                particle.position.x = Float(particle.size)
                particle.velocity.x *= -1 * Constants.velocityDampening
            }
            
            self.drawParticle(particle: particle, char: particle.displayChar)
        }
    }
    
    func drawParticle(particle: Particle, char: String) {
        for angle in stride(from: 0, to: 360, by: Constants.drawStepAngle) {
            var offset = Vector(cos(Float(angle)), sin(Float(angle))).scale(Float(particle.size) + Float(Constants.bounceLayer))
            var targetPosition = Vector(particle.position.y, particle.position.x).add(offset)
            
            var x = min(self.width - 1, max(0, Int(round(targetPosition.x))))
            var y = min(self.height - 1, max(0, Int(round(targetPosition.y))))
            
            self.content[x][y] = char
        }
    }
    
    func clear() {
        self.content = Array(repeating: Array(repeating: self.emptyChar, count: self.width), count: self.height)
    }
    
    func draw() {
        print(String(repeating: "-", count: self.width * 2))
        for row in self.content {
            print("|" + row.joined(separator: " ") + "|")
        }
        print(String(repeating: "-", count: self.width * 2))
    }
    
}

struct Constants {
    static let g = Vector(0, 0.5)
    static let dragCoefficient: Float = 0
    static let velocityDampening: Float = 0.75
    static let velocityThreshold: Float = 0.3
    static let drawStepAngle: Int = 5
    static let bounceLayer: Int = 0
}

var display = Display(width: 55, height: 55, emptyChar: " ")
var particle = Particle(displayChar: "■", size: 2, position: Vector(15, 15))
display.particles.append(particle)

particle.velocity = Vector(3, 5)

while true {
    particle.acceleration = Constants.g
    display.update()
    display.draw()
    
    print(particle.velocity.toString())
    
    usleep(100000)
    print("\u{001B}[2J")
}
