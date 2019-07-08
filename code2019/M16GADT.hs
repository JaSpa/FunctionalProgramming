{-# LANGUAGE GADTs #-}
module M16GADT where

-- ^ A regular interpreter with multiple types.
    
data Term0 =
    I0 Integer
  | B0 Bool
  | Add0 Term0 Term0
  | Eq0 Term0 Term0
    deriving (Eq, Show)
                      
data Value = Int Integer | Bool Bool
             deriving (Eq, Show)
      
eval0           :: Term0 -> Value
eval0 (I0 n)      = Int n
eval0 (B0 b)      = Bool b
eval0 (Add0 t t') = case (eval0 t, eval0 t') of
                      (Int i, Int i2) -> Int (i + i2)
eval0 (Eq0 t t')  = case (eval0 t, eval0 t') of
                      (Int i, Int i2) -> Bool (i == i2)
                      (Bool i, Bool i2) -> Bool (i == i2)

termGood0 = Eq0 (I0 3) (Add0 (I0 2) (I0 1))
termBad0 = Eq0 (I0 3) (B0 True)











           
-- ^ "Tag-less" interpreter with GADTs

data Term a where
  I :: Integer -> Term Integer
  B :: Bool -> Term Bool
  D :: Double -> Term Double
  N :: (Num x) => x -> Term x
  Add :: (Num x) => Term x -> Term x -> Term x
  Eq :: (Eq x) => Term x -> Term x -> Term Bool

eval :: Term a -> a -- This type annotation is mandatory
eval (I i) = i
eval (B b) = b
eval (D d) = d
eval (N n) = n
eval (Add t t') = eval t + eval t'
eval (Eq t t') = eval t == eval t'

termGood =  Eq (I 3) (Add (I 2) (I 1))
-- termBad = Eq (I 3) (B True)


-- de Bruijn notation (a calculus of nameless dummies)
example = \ x -> x         --  \ 0  -- refers to the next enclosing lambda
exampl0 = \ x -> \ y -> x  --  \ \ 1  -- refers to the outermost lambda
exampl1 = \ f -> \ x -> f x -- \ \ (1 0)
exampl2 = \ x y z -> (x z) (y z) -- \ \ \ (2 0) (1 0)











ve :: (Int, (Int, (Bool, ())))
ve = undefined





-- ^ GADT interpreter with functions
-- "typed lambda calculus with constants"

data FExp e a where
  Con :: a -> FExp e a
  App :: FExp e (a -> b) -> FExp e a -> FExp e b
  Lam :: FExp (a, e) b -> FExp e (a -> b)
  Var :: Nat e a -> FExp e a

data Nat e a where
  Zero :: Nat (a, b) a
  Succ :: Nat e a -> Nat (b, e) a

-- \lambda x.x        -- the I combinator
ex1 = Lam (Var Zero)
-- \x\y.x  -- the K combinator
ex2 = Lam (Lam (Var (Succ Zero)))
-- \f\x. f x
ex3 = Lam (Lam (App (Var (Succ Zero)) (Var Zero)))
-- the S combinator \x\y\z -> (x y) (y z)
ex4 = Lam (Lam (Lam (App (App (Var (Succ (Succ Zero))) (Var Zero))
                         (App (Var (Succ Zero)) (Var Zero)))))


type Program a = FExp () a

lookupNat :: Nat e a -> e -> a
lookupNat Zero (a, b) = a
lookupNat (Succ p) (_, b) = lookupNat p b

feval :: e -> FExp e a -> a
feval e (Con v) = v
feval e (App f x) = (feval e f) (feval e x)
feval e (Lam b) = \x -> feval (x, e) b
feval e (Var p) = lookupNat p e













-- ^ Existential types

data Package where
  Package :: (a -> Int) -> a -> Package

package1 = Package (+1) 41
package2 = Package length [1,2,3]
package3 = Package length "sdkfh"
package4 = Package fst (12, undefined)


unpack :: Package -> Int
unpack (Package f a) = f a


data PackageN where
  PackageN :: Num a => (a -> Int) -> a -> PackageN

package1a = PackageN fromInteger 92384729384729384

unpackN :: PackageN -> Int
unpackN (PackageN f a) = let b = a * a in f b

-- -- This doesn't work
-- getFun :: Package -> (a -> Int) -- Who is `a` ?
-- getFun (Package f _) = f










