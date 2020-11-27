from bs4 import BeautifulSoup
from collections import Counter
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


def parse_file_content(infile):
    content = None
    with open(infile) as fin:
        content = fin.read().encode("utf-8")
    soup = BeautifulSoup(content, "html.parser")
    items = soup.find_all(class_="event-list-single-item")
    parsed_items = []
    for i in items:
        name = ""
        desc = ""

        scheduling_elem = i.find_all(class_="event-list-item__scheduling")
        scheduling = "".join([el.string if el else "" for el in scheduling_elem])

        tags_elem = i.find_all(class_="tag")
        tags = [el.string if el else "" for el in tags_elem]
        tags = ",".join([el.string for el in tags])
        tags_string = tags.lower() if tags else ""

        name_elem = i.find_all(class_="event-list-item__name")
        if len(name_elem) > 0:
            name = "".join([el.get_text() if el else "" for el in name_elem])

        desc_elem = i.find_all(class_="event-list-item__description")
        if len(desc_elem) > 0:
            desc = "".join([el.get_text() if el else "" for el in desc_elem])

        parsed_items.append(
            {
                "name": f"{name}",
                "schedule": scheduling,
                "description": desc,
                "tags": f"{tags_string}",
            }
        )

    return parsed_items


def filter_data_by_command_line_argument(
    infile,
    tag_str=None,
    date_str=None,
):
    indata = parse_file_content(infile)
    language_filter = BuiltIn().get_variable_value("${LANGUAGE_FILTER}")
    rows = []
    tag_cloud = []
    for row in indata:
        tag_match = True
        date_match = True
        row_tags = row["tags"].split(",")
        schedule = row["schedule"].lower()
        skip = False
        for x in row_tags:
            tag_cloud.append(x)
            if x in language_filter:
                skip = True
        if skip:
            continue
        if tag_str and tag_str not in row["tags"]:
            tag_match = False
        if date_str and date_str.lower() not in schedule:
            date_match = False
        if tag_match and date_match:
            rows.append(row)
    counter = Counter(tag_cloud)
    return rows, counter


def print_tag_statistics(cloud):
    for elem in cloud.most_common():
        logger.console(f"{elem[0]}: {elem[1]}")
