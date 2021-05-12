package challenge.hello;

class InformationNotFoundException extends RuntimeException {

	  InformationNotFoundException(Long id) {
	    super("Could not find information " + id);
	  }
}
