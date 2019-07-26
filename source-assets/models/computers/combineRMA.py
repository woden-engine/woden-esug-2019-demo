#!/usr/bin/python
import sys
from PIL import Image
from PIL import ImageCms

def srgbDecode(point):
	value = point/255.0
	if value <= 0.04045:
		value = value / 12.92
	else:
		value = ((value + 0.055)/1.055)**2.4

	result = int(value *255 + 0.5)
	if result < 0: return 0
	if result > 255: return 255
	return result

def main():
	if len(sys.argv) < 5:
		print 'combineRMA.py roughness metallic ao rma'
		return

	srgbProfile = ImageCms.createProfile('sRGB')
	linearProfile = ImageCms.createProfile('sRGB')

	roughnessImageName = sys.argv[1]
	metallicImageName = sys.argv[2]
	aoImageName = sys.argv[3]
	rmaImageName = sys.argv[4]

	roughnessImage = Image.open(roughnessImageName)
	metallicImage = Image.open(metallicImageName)
	aoImageName = Image.open(aoImageName)
	g = roughnessImage.split()[1].point(srgbDecode)
	b = metallicImage.split()[2].point(srgbDecode)
	r = aoImageName.split()[0].point(srgbDecode)
	
	rmaImage = Image.merge("RGB", (r, g, b))
	rmaImage.save(rmaImageName, "PNG")

main()
