{
	description = "monkey-language";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = inputs: 
	let
		pkgs = import inputs.nixpkgs {
			system = "x86_64-linux";
		};
	in {
		devShells.x86_64-linux.default = pkgs.mkShell {
			buildInputs = [
				pkgs.zig
			];
		};
	};
}
