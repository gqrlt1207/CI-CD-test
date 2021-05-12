package challenge.hello;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
class HelloController {

  private final HelloRepository repository;

  HelloController(HelloRepository repository) {
    this.repository = repository;
  }


  // Aggregate root
  // tag::get-aggregate-root[]
  @GetMapping("/hello/all")
  List<Information> all() {
    return repository.findAll();
  }
  
  @GetMapping("/hello")
  Information welcome() {
	  	Long id = (long) 1;
	    return repository.findById(id)
	      .orElseThrow(() -> new InformationNotFoundException(id));
	  }
  // end::get-aggregate-root[]

  @PostMapping("/hello")
  Information newInformation(@RequestBody Information newInformation) {
    return repository.save(newInformation);
  }

  // Single item
  
  @GetMapping("/hello/{id}")
  Information one(@PathVariable Long id) {
    
    return repository.findById(id)
      .orElseThrow(() -> new InformationNotFoundException(id));
  }

  @PutMapping("/hello/{id}")
  Information replaceInformation(@RequestBody Information newInformation, @PathVariable Long id) {
    
    return repository.findById(id)
      .map(information -> {
        information.setInfo(newInformation.getInfo());
        return repository.save(information);
      })
      .orElseGet(() -> {
        newInformation.setId(id);
        return repository.save(newInformation);
      });
  }

  @DeleteMapping("/hello/{id}")
  void deleteEmployee(@PathVariable Long id) {
    repository.deleteById(id);
  }
}
