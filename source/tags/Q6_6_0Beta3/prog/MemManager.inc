
(* Determines the memory manager to use. Only use MemTester for releases, since the other one currently are not supported! *)

{$DEFINE MemTester}   (*Default MemTester unit*)
{.$DEFINE FastMM}      (*Enable for FastMM, copy the debug DLL to the runtime directory when debugging*)
{.$DEFINE MemCheck}    (*Enable for MemCheck*)
