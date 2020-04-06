# The Intermediate Representation 

Prior to any analysis, we transcribe the code of our contracts into a different, 
more abstract representation that is much easier to work with. Our intermediate 
representation encodes the semantics of a contract in a control flow graph. Put
simply, the nodes of a CFG correspond to program statements while edges between
the nodes encode the sequence in which statements can be executed. Therefore, a 
CFG conveniently represents all possible paths that a program might take during 
execution.

Our CFG representation is constituted of three main elements: statements, basic 
blocks and transfers.


## Statements
CFG statements simply correspond to elementary operations in the contract, such 
as assignments, unary and binary operations, as well as accesses to any storage
variables. Complex program statements such as `s = (a + b) * 10` are decomposed
into basic operations (e.g. `tmp1 = a + b`, `tmp2 = tmp1 * 10` and `s = tmp2`). 
Hence, our representation is in static single assignment form. Still, we do not 
explicitly introduce new variables for temporary results. Instead, we treat the 
respective CFG objects (i.e. instances of `cfg_ir.Expression`) as the temporary 
variables required for our SSA form.

Statements are represented as instances of `cfg_ir.Statement` that reference an
instance of `cfg_ir.Expression`. Note that this also holds for statements which 
do not have an explicit expression value (e.g. storage writes). 


## Basic Blocks
Basic blocks encapsulate statements that will be executed consecutively without
any branching instructions or function invocations in between. Each block takes 
a list of zero or more input arguments and is terminated by a block transfer. A 
transfer can represent a conditional branching (e.g. for an `if` structure), an 
unconditional branching (e.g. a simple goto instruction), a function call, or a 
return (more on that in the next section). 
All transfers except for returns reference one or more basic blocks that can be 
executed after the current block. Hence, blocks are linked via the transfers.

Here is a schematic example of a basic block:

```
Anatomy of a basic block: 

=================
Block B 
-----------------
Arg0, Arg1, ... 
-----------------
Statement 1
Statement 2
...
Statement N
-----------------
Transfer
=================

```

The arguments of basic blocks can be thought of as implicit SSA assignments. As 
such they are represented by instances of `cfg_ir.Expression` just as any other 
local variable.  

Note that the transfer is not part of the list of statements. 

## Transfers
We define four types of transfers: 
 * unconditional branching transfers (`cfg_ir.Goto`), 
 * conditional branching transfers (`cfg_ir.Branch`), 
 * function call transfers (`cfg_ir.Jump`) and 
 * return transfers (`cfg_ir.Return`). 

Just as each basic block has a list of input arguments, all transfers come with
a list of argument values which are passed to the basic blocks they reference. 
With this mechanism, we represent data flow between basic blocks. 

Please note that multiple transfers can reference the same basic block (e.g. as 
in a join of two branches). 

### Unconditional Branching Transfer
The unconditional branching transfer simply references a following basic block. 
It is used for joining of program branches (almost) exclusively.

### Conditional Branching Transfer
The branch transfer is used to implement conditional transfers which are needed 
to  model complex control structures such as `if`, `while` and `for` statements.
As such, and in contrast to unconditional branching transfers, each conditional 
branching transfer references two following basic blocks. Consequently, it also 
has two separate lists of arguments that are passed to the corresponding blocks. 
Furthermore, it holds a reference to the conditional expression that determines 
which branch to take.

### Jump Transfers
Function calls within a single contract are represented by jump transfers. They 
are similar to unconditional transfers, in the sense that they reference just a 
single basic block to be executed next (as opposed to the conditional transfer). 
However, they also define a continuation block which is the block to returns to 
after the called function has been executed.

### Return Transfers
Return transfers terminate basic-blocks without specifying a following block to 
execute next. They correspond to return statements in functions. In a way, they
are the counterpart to the jump transfers, as the next block to execute after a 
return transfer is determine by the continuation block of the jump which led to 
the return transfer in the first place. 


# Datalog Representation of CFGs

The transcription of the CFG representation into Datalog facts is very straight 
forward. Instances of CFG classes defined in `cfg_ir` are translated to datalog 
facts almost verbatim. 

## Blocks
* For each block `cfg_ir.Block` we have a fact in the `block(blockId)` relation.
* Block arguments are associated with their corresponding block via the 
        `argument(argId, blockId, argIndex)` relation.
* Statements are associated with the block they appear in via the 
        `blockStmt(blockId, stmtId)` relation.
* Entry blocks for functions are tagged by the 
        `function(blockId, functionName)` relation.
        
## Statements
* For each statement `cfg_ir.Statement` we have facts in one of these relations:
  * Assignments `assign(targetId, valueId)`
  * Unary operations `uop(targetId, valueId, operatorType)`
  * Binary operations 
        `uop(targetId, leftHandValueId, rightHandValueId, operatorType)`
  * Constants `const(constId, value)`
  * Storage variable reads `load(targetId, fieldName)`
  * Storage variable writes `store(targetId, fieldName, valueId)`
  * Struct loads `structLoad(targetId, object, value)` 
        (only used for `msg.sender` and `mst.value`)
* Statements within a basic block are linked via the 
    `follows(next, prev)` relation
* Statements are described via unique IDs are elements of the `SSA` type domain.

## Transfers
* Transfers are encoded in the following relations
  * Unconditional branching transfers `goto(transferId, blockFromId, blockToId)`
  * Conditional branching transfers 
        `branch(transferIdTrue, transferIdFalse, blockFromId, 
            blockToIdTrue, blockToIdFalse)`
  * Jump `jump(transferId, blockFromId, blockToId, blockContinueId)`
  * Return `return(transferId, blockFromId)`
* Transfers are linked to their respective arguments via the 
    `tranasferArgument(transferId, argumentValueId, index)` relation.


## Example 

To illustrate the above description, we will have a look at some of the Datalog 
facts for the following program: 

```
pragma solidity ^0.5.0;

contract A {
    uint state = 0;

    function test() public returns (uint) {
        uint x = 3;
        uint y = 5;
        uint z = 0;

        if (msg.value > 10) {
            z = add(x, y);
        } else {
            z = add(x, -y);
        }

        return z;
    }

    function add(uint a, uint b) {
        return a + b;
    }
}
```

## Encoding of Blocks
There are 7 basic blocks in the program. For each block we have a `block` fact:
```
block("B00"). // (BlockID: Block)
block("B01").
...
```

There are two functions in the program, each of which has an entry block:
```
function("B00", "test"). // (BlockID: Block) -> (FunctionName: symbol)
function("B02", "add").
```

Some of the blocks take arguments (e.g. the entry block for `test`):
```
argument("A00", "B02", 0). // ArgumentID: SSA; BlockID: Block; ArgIndex: Number
argument("A01", "B02", 1). 
```

## Encoding of Statements
Let's look at the facts for the statements in basic block `B02`:

The IDs of the statements in the block are encoded as follows:
```
blockStmt("B02", "S09"). // (BlockID: Block) -> (StmtID: SSA)
blockStmt("B02", "S10").
blockStmt("B02", "S11").
```

The statements themselves are encoded with these facts: 
```
assign("S09", "A00"). // Assign argument A00 to local variable at S09
assign("S10", "A01"). // Assign argument A01 to local variable at S10
bop("S11", "S09", "S10", "+"). // Add variables S09 and S10; result is in S11
```

Note that statement IDs are used interchangeably with SSA assignment IDs.

The ordering between the statements in the context of their corresponding block
is established by the `follows` relation:
```
follows("S10", "S09").
follows("S11", "S10").
... 
```

## Encoding of Transfers
There are multiple transfers in our example program. We will take a closer look
at the `branch` and `return` transfers.
 
```
// Branch transfers 
// TransferIdTrue, TransferIdFalse, BlockFrom, BlockToTrue, BlockToFalse, ConditionID
branch("T00_TRUE", "T00_FALSE", "B00", "B01", "B05", "S08").


// Jump transfers 
// TransferId, BlockFrom, BlockTo, BlockContinuation
jump("T01", "B01", "B02", "B03").

// Return transfers 
// TransferId, BlockFrom 
return("T02", "B02").
return("T04", "B04").
```

Each transfer fact has a unique transfer ID. For the `branch` fact we even have 
two transfer ids, one for each branch. 

Argument values of the transfers are encoded as follows: 
```
transferArgument("T01", "S01", "0").
transferArgument("T01", "S03", "1").

transferArgument("T02", "S11", 0). // TransferID: Transfer; ArgValue: SSA; ArgIndex: Number
transferArgument("T04", "S13", 0).
```

These are the argument values that are passed with each transfer. Note that the
`branch` transfer do not have any arguments in this example. 

From the above facts we know that `T01` jumps from block `B01` into `B02`. Also
we know that `B02` takes two arguments (c.f. `argument("A00/A01", "B02", 0/1)`) 
and from `transferArgument("T01", "S01/S03", 0/1)` we know which arguments will
be passed in this call (note multiple arguments can be matched via the indices). 
Furthermore we know that as soon as a `return` has been reached after we jumped 
to `B02` the program continues the execution with `B03` which is encoded in the 
`jump` fact as well.  