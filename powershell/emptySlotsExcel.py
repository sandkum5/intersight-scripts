#!/usr/bin/env python3
"""
    Script to parse data.json file generated by findEmptySlots.ps1 and create an Excel with color codes cells with slot info
    Slot Options: Equipped or Available
"""
import json
# import csv
import xlsxwriter

with open('data.json', 'r') as f:
    data = f.read()

jdata = json.loads(data)

# Excel Header Fields
fields = ["DomainName", "ChassisId", "Slot_1", "Slot_2", "Slot_3", "Slot_4", "Slot_5", "Slot_6", "Slot_7", "Slot_8"]

# Create a list of Rows for Excel file
rows = []
for domain, data in jdata.items():
    for chassis, slots in data.items():
        row = []
        row.append(domain)
        row.append(f"Chassis_{chassis}")
        chassis_slots = ('1', '2', '3', '4', '5', '6', '7', '8')
        for x in chassis_slots:
            slot_key = f"Slot_{x}"
            if x in slots:
                row.append("Equipped")
            else:
                row.append("Available")
        rows.append(row)


# Create Excel File
workbook = xlsxwriter.Workbook('EmptySlots.xlsx')
worksheet = workbook.add_worksheet('EmptySlots')

# cell_format = workbook.add_format({'bold': True})
cell_format = workbook.add_format()
cell_format.set_bold()
cell_format.set_font_size(15)
# cell_format.set_font_name('Bodoni MT Black')
# cell_format.set_font_color('blue')

worksheet.write('A1', 'DomainName', cell_format)
worksheet.write('B1', 'ChassisId', cell_format)
worksheet.write('C1', 'Slot_1', cell_format)
worksheet.write('D1', 'Slot_2', cell_format)
worksheet.write('E1', 'Slot_3', cell_format)
worksheet.write('F1', 'Slot_4', cell_format)
worksheet.write('G1', 'Slot_5', cell_format)
worksheet.write('H1', 'Slot_6', cell_format)
worksheet.write('I1', 'Slot_7', cell_format)
worksheet.write('J1', 'Slot_8', cell_format)

# write(row, column, token, [format])
# Start from the first cell. Rows and columns are zero indexed.
row = 1
col = 0

cell_format_green = workbook.add_format({'bold': False, 'font_color': 'green'})
cell_format_red = workbook.add_format({'bold': False, 'font_color': 'red'})

for domain, chassis, slot1, slot2, slot3, slot4, slot5, slot6, slot7, slot8 in (rows):
    # Convert the date string into a datetime object.
    worksheet.write_string(row, col, domain)
    worksheet.write_string(row, col+1, chassis)
    if slot1 == "Available":
        worksheet.write_string(row, col+2, slot1, cell_format_green)
    elif slot1 == "Equipped":
        worksheet.write_string(row, col+2, slot1, cell_format_red)
    if slot2 == "Available":
        worksheet.write_string(row, col+3, slot1, cell_format_green)
    elif slot2 == "Equipped":
        worksheet.write_string(row, col+3, slot1, cell_format_red)
    if slot3 == "Available":
        worksheet.write_string(row, col+4, slot1, cell_format_green)
    elif slot3 == "Equipped":
        worksheet.write_string(row, col+4, slot1, cell_format_red)
    if slot4 == "Available":
        worksheet.write_string(row, col+5, slot1, cell_format_green)
    elif slot4 == "Equipped":
        worksheet.write_string(row, col+5, slot1, cell_format_red)
    if slot5 == "Available":
        worksheet.write_string(row, col+6, slot1, cell_format_green)
    elif slot5 == "Equipped":
        worksheet.write_string(row, col+6, slot1, cell_format_red)
    if slot6 == "Available":
        worksheet.write_string(row, col+7, slot1, cell_format_green)
    elif slot6 == "Equipped":
        worksheet.write_string(row, col+7, slot1, cell_format_red)
    if slot7 == "Available":
        worksheet.write_string(row, col+8, slot1, cell_format_green)
    elif slot7 == "Equipped":
        worksheet.write_string(row, col+8, slot1, cell_format_red)
    if slot8 == "Available":
        worksheet.write_string(row, col+9, slot1, cell_format_green)
    elif slot8 == "Equipped":
        worksheet.write_string(row, col+9, slot1, cell_format_red)
    row += 1

workbook.close()

# Create CSV File
# csvfile = "emptyslots.csv"
# with open(csvfile, 'w') as csvfile:
#     # creating a csv writer object
#     csvwriter = csv.writer(csvfile)

#     # writing the fields
#     csvwriter.writerow(fields)

#     # writing the data rows
#     csvwriter.writerows(rows)
