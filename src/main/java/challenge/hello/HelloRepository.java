package challenge.hello;

import org.springframework.data.jpa.repository.JpaRepository;

interface HelloRepository extends JpaRepository<Information, Long> {

}


