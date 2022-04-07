// ChangeBSPSignature
// Version 1.2
// 7 April 2022
// (c) Copyright 2022, DanielPharos

// This program changes the signature on BSP files.
// It cannot CONVERT different BSP file types.
// It was written so QuArK can use the Heavy Metal: FAKK2 compiler for American McGee's Alice.

#include <iostream>
#include <fstream>
using namespace std;

#define VersionString "1.2"

// This is supposed to be a single byte datatype:
#define byte unsigned char

struct cGame
{
	char* ID;
	char* Name;
	byte* Signature;
	byte* Version;
};

const int GameNR = 10;
const cGame GameList[GameNR] = {
	{ "Alice", "American McGee's Alice", reinterpret_cast<byte*>("FAKK"), reinterpret_cast<byte*>("\x2A\x00\x00\x00") },
	{ "DK", "Daikatana", reinterpret_cast<byte*>("\x49\x42\x53\x50"), reinterpret_cast<byte*>("\x29\x00\x00\x00") },
	{ "HL", "Half-Life", reinterpret_cast<byte*>("\x1E\x00\x00\x00"), nullptr },
	{ "FAKK2", "Heavy Metal: FAKK2", reinterpret_cast<byte*>("FAKK"), reinterpret_cast<byte*>("\x0C\x00\x00\x00") },
	{ "Q1", "Quake 1 or Hexen II", reinterpret_cast<byte*>("\x1D\x00\x00\x00"), nullptr },
	{ "Q2", "Quake 2", reinterpret_cast<byte*>("\x49\x42\x53\x50"), reinterpret_cast<byte*>("\x26\x00\x00\x00") },
	{ "Q3", "Quake 3 or Nexuiz", reinterpret_cast<byte*>("\x49\x42\x53\x50"), reinterpret_cast<byte*>("\x2E\x00\x00\x00") },
	{ "RTCW", "Return to Castle Wolfenstein", reinterpret_cast<byte*>("\x49\x42\x53\x50"), reinterpret_cast<byte*>("\x2F\x00\x00\x00") },
	{ "SiN", "SiN or Star Wars: Jedi Knight 2 or Star Wars: Jedi Academy", reinterpret_cast<byte*>("\x52\x42\x53\x50"), reinterpret_cast<byte*>("\x01\x00\x00\x00") },
	{ "W", "Warsow", reinterpret_cast<byte*>("\x46\x42\x53\x50"), reinterpret_cast<byte*>("\x01\x00\x00\x00") }
};

/* // Note: Quake-3 and STVEF .BSPs, uses the same signature as Quake-2 .BSPs!
 cSignatureBspQ3      = $50534252; {"RBSP" 4-letter header}
 cSignatureMohaa      = $35313032;

(***********  Half-Life 2 .bsp format  ***********)

const
 cSignatureHL2        = $50534256; {"VBSP" 4-letter header, which HL2 contains}

 cVersionBspHL2       = $00000013; {HL2}
 cVersionBspHL2HDR    = $00000014; {HL2 with HDR lighting}*/

int main(int argc, char* argv[])
{
	bool DisplayUsage = false;
	cout << "ChangeBSPSignature - version " VersionString << endl;
	cout << endl;
	if (argc == 2)
	{
		if (!strcmp(argv[1], "-games"))
		{
			cout << "Supported games:" << endl;
			for (size_t i = 0; i < GameNR; ++i)
			{
				cout << "\"" << GameList[i].ID << "\" = " << GameList[i].Name << endl;
			}
			return 0;
		}
	}
	if ((argc < 2) || (argc > 4))
	{
		cout << "Wrong number of arguments!" << endl;
		DisplayUsage = true;
	}
	if (DisplayUsage)
	{
		cout << "Usage:" << endl;
		cout << "ChangeBSPSignature bspfile [WantedGame [FileGame]]" << endl;
		cout << endl;
		cout << "Type 'ChangeBSPSignature -games' (without quotes) for a list of all supported games." << endl;
		cout << endl;
		return 1;
	}
	size_t WantGameMode = GameNR;
	if (argc > 2)
	{
		for (size_t i = 0; i < GameNR; ++i)
		{
			if (!strcmp(argv[2], GameList[i].ID))
			{
				WantGameMode = i;
				break;
			}
		}
		if (WantGameMode == GameNR)
		{
			cout << "Invalid second parameter. Game not recognized." << endl;
			cout << "Type 'ChangeBSPSignature -games' (without quotes) for a list of all supported games." << endl;
			cout << endl;
			return 1;
		}
	}
	size_t FileGameMode = GameNR;
	if (argc > 3)
	{
		for (size_t i = 0; i < GameNR; ++i)
		{
			if (!strcmp(argv[3], GameList[i].ID))
			{
				FileGameMode = i;
				break;
			}
		}
	}
	if (FileGameMode == GameNR)
	{
		cout << "Invalid third parameter. Game not recognized." << endl;
		cout << "Type 'ChangeBSPSignature -games' (without quotes) for a list of all supported games." << endl;
		cout << endl;
		return 1;
	}
	fstream BSPFile;
	ios_base::openmode FileMode;
	if (WantGameMode == GameNR)
	{
		FileMode = ios::in | ios::binary;
	}
	else
	{
		FileMode = ios::in | ios::out | ios::binary;
	}
	BSPFile.open(argv[1], FileMode);
	if (!BSPFile.is_open())
	{
		cout << "Unable to open BSP file." << endl;
		cout << endl;
		return 1;
	}
	byte* BufferSignature;
	BufferSignature = new byte [4];
	BSPFile.seekg(0, ios::beg);
	BSPFile.read(reinterpret_cast<char*>(BufferSignature), 4);
	if (BSPFile.fail())
	{
		cout << "Corrupt BSP file." << endl;
		cout << endl;
		delete[] BufferSignature;
		BSPFile.close();
		return 1;
	}
	byte* BufferVersion = nullptr;
	if (GameList[FileGameMode].Version)
	{
		BufferVersion = new byte [4];
		BSPFile.read(reinterpret_cast<char*>(BufferVersion), 4);
		if (BSPFile.fail())
		{
			cout << "Corrupt BSP file." << endl;
			cout << endl;
			delete[] BufferSignature;
			delete[] BufferVersion;
			BSPFile.close();
			return 1;
		}
	}
	if (FileGameMode == GameNR)
	{
		for (size_t i = 0; i < GameNR; ++i)
		{
			if (!memcmp(BufferSignature, GameList[i].Signature, 4))
			{
				if (GameList[i].Version)
				{
					if (!memcmp(BufferVersion, GameList[i].Version, 4))
					{
						FileGameMode = i;
						break;
					}
				}
				else
				{
					FileGameMode = i;
					break;
				}
			}
		}
	}
	if (FileGameMode == GameNR)
	{
		cout << "Couldn't recognize BSP file game. This might not be a valid BSP file, or the game for which it is written is not supported by ChangeBSPSignature. Program terminated." << endl;
		delete [] BufferSignature;
		if (!BufferVersion)
		{
			delete [] BufferVersion;
		}
		BSPFile.close();
		return 1;
	}
	cout << "BSP file game: " << GameList[FileGameMode].Name << endl;
	if (WantGameMode == GameNR)
	{
		cout << "No changes made." << endl;
		delete [] BufferSignature;
		if (!BufferVersion)
		{
			delete [] BufferVersion;
		}
		BSPFile.close();
		return 0;
	}
	if (WantGameMode == FileGameMode)
	{
		cout << "BSP file game already correct. No changes made." << endl;
	}
	else
	{
		cout << "Changing BSP file game...";
		BSPFile.seekp(0, ios::beg);
		BSPFile.write(reinterpret_cast<char*>(GameList[WantGameMode].Signature), 4);
		if (GameList[WantGameMode].Version)
		{
			BSPFile.write(reinterpret_cast<char*>(GameList[WantGameMode].Version), 4);
		}
		cout << " done!" << endl;
	}
	delete [] BufferSignature;
	if (!BufferVersion)
	{
		delete [] BufferVersion;
	}
	BSPFile.close();
	return 0;
}
