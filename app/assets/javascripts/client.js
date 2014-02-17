function send_json(addr, data, good, bad) {
  $.ajax({
    type: 'POST',
    url: addr,
    data: JSON.stringify(data),
    contentType: "application/json",
    dataType: "json",
    success: good,
    error: bad
  });
}

function toMessage(errCode) {
  if (errCode == -1) {
    return "Invalid username and password combination. Please try again.";
  } else if (errCode == -2) {
    return "This user name already exists. Please try again.";
  } else if (errCode == -3) {
    return "The user name should not be empty and at most 128 characters long. Please try again.";
  } else if (errCode == -4) {
    return "The password should be at most 128 characters long. Please try again.";
  } else {
    return "Unknown error occured: " + errCode;
  }
}
