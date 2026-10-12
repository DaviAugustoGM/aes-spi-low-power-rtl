from Crypto.Cipher import AES

key = b"I see the messag"

encrypted = input("Mensagem criptografada (HEX): ")

aes = AES.new(key, AES.MODE_ECB)
decrypted = aes.decrypt(bytes.fromhex(encrypted))

print("Mensagem original:", decrypted.decode("utf-8"))
