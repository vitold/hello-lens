{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}

module Examples where

import           Control.Lens
import           Control.Lens.Fold
import           Control.Lens.Setter
import           Control.Monad.Trans.State

data Nested2 = Nested2
  { _field5::Int
  } deriving (Show)

makeLenses ''Nested2

data Nested1 = Nested1
  { _field3::String
  , _field4::[Nested2]
  } deriving (Show)

makeLenses ''Nested1


data TopLevel = TopLevel
  { _field1 :: String
  , _field2 :: [Nested1]
  } deriving (Show)

makeLenses ''TopLevel

initial = TopLevel
  { _field1 = "field_value1"
  , _field2 =
    [ Nested1
      { _field3 = "field3_value1"
      , _field4 =
        [ Nested2 {_field5 = 1}
        , Nested2 {_field5 = 2}
        ]}
    , Nested1
      { _field3 = "field3_value2"
      , _field4 =
        [ Nested2 {_field5 = 3}
        , Nested2 {_field5 = 4}
        ]}
    ]
  }

--View field5 from nested lists:
--λ> :t toListOf
--  toListOf :: Getting (Data.Monoid.Endo [a]) s a -> s -> [a]
--λ> :t traverse
--  traverse
--    :: (Applicative f, Traversable t) => (a -> f b) -> t a -> f (t b)
viewFields5 = toListOf (field2 . traverse . field4 . traverse . field5) initial

--Update fields in nested lists based on predicate
--λ> :t execState
--  execState :: State s a -> s -> s
--λ> :t traversed
--traversed
--  :: (Applicative f2, Traversable f1, Indexable Int p) =>
--     p a (f2 b) -> f1 a -> f2 (f1 b)
--λ> :t filtered
--filtered
--  :: (Applicative f, Choice p) => (a -> Bool) -> Optic' p f a a
updateFields5 = execState (field2 . traverse . field4 . traversed . filtered greaterThen2 . field5 -= 1) initial

--Predicate for selecting elements to update
greaterThen2 x =  x ^. field5 > 2

--View nested arrays elements filtered by predicate
filterField2 = toListOf (field2 . traverse . field4 . traversed . filtered greaterThen2) initial

