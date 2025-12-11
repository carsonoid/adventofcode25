; Variables for how many times each button is pressed (non-negative integers)
(declare-const b0 Int)  ; button 0: (0,2,3,4)
(declare-const b1 Int)  ; button 1: (2,3)
(declare-const b2 Int)  ; button 2: (0,4)
(declare-const b3 Int)  ; button 3: (0,1,2)
(declare-const b4 Int)  ; button 4: (1,2,3,4)

; Constrain buttons to be non-negative
(assert (>= b0 0))
(assert (>= b1 0))
(assert (>= b2 0))
(assert (>= b3 0))
(assert (>= b4 0))

; Target values are {7,5,12,7,2}
; Each position's final value is the sum of all buttons that affect it

; Position 0: affected by buttons 0, 2, 3 -> target 7
(assert (= (+ b0 b2 b3) 7))

; Position 1: affected by buttons 3, 4 -> target 5
(assert (= (+ b3 b4) 5))

; Position 2: affected by buttons 0, 1, 3, 4 -> target 12
(assert (= (+ b0 b1 b3 b4) 12))

; Position 3: affected by buttons 0, 1, 4 -> target 7
(assert (= (+ b0 b1 b4) 7))

; Position 4: affected by buttons 0, 2, 4 -> target 2
(assert (= (+ b0 b2 b4) 2))

; Minimize the total number of button presses
(minimize (+ b0 b1 b2 b3 b4))

(check-sat)
(get-model)
