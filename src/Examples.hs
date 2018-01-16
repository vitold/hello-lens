{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE OverloadedStrings #-}

module Examples where

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

--View field5 from nested lists
viewFields5 = toListOf (field2 . traverse . field4 . traverse . field5) initial

--Update fields in nested lists based on predicate
updateFields5 = execState (field2 . traverse . field4 . traversed . filtered greaterThen2 . field5 -= 1) initial

--Predicate for selecting elements to update
greaterThen2 x =  x ^. field5 > 2

--View nested arrays elements filtered by predicate
filterField2 = toListOf (field2 . traverse . field4 . filtered greaterThen2) initial

