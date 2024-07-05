import 'package:solana/dto.dart';
import 'package:solana/encoder.dart' as encoder;
import 'package:solana/solana.dart';

class AssociatedTokenAccountInstruction extends encoder.Instruction {
  factory AssociatedTokenAccountInstruction.createAccount({
    required Ed25519HDPublicKey funder,
    required Ed25519HDPublicKey address,
    required Ed25519HDPublicKey owner,
    required Ed25519HDPublicKey mint,
  }) =>
      AssociatedTokenAccountInstruction._(
        accounts: [
          encoder.AccountMeta.writeable(pubKey: funder, isSigner: true),
          encoder.AccountMeta.writeable(pubKey: address, isSigner: false),
          encoder.AccountMeta.readonly(pubKey: owner, isSigner: false),
          encoder.AccountMeta.readonly(pubKey: mint, isSigner: false),
          encoder.AccountMeta.readonly(
            pubKey: Ed25519HDPublicKey.fromBase58(SystemProgram.programId),
            isSigner: false,
          ),
          encoder.AccountMeta.readonly(
            pubKey: Ed25519HDPublicKey.fromBase58(TokenProgram.programId),
            isSigner: false,
          ),
          encoder.AccountMeta.readonly(
            pubKey: Ed25519HDPublicKey.fromBase58(encoder.Sysvar.rent),
            isSigner: false,
          ),
        ],
      );

  AssociatedTokenAccountInstruction._({
    required super.accounts,
  }) : super(
    programId: AssociatedTokenAccountProgram.id,
    data: const encoder.ByteArray.empty(),
  );
}




