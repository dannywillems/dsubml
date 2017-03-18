exception SubtypeError of string * Grammar.nominal_typ * Grammar.nominal_typ

exception AvoidanceProblem of string * AlphaLib.Atom.t * Grammar.nominal_typ
