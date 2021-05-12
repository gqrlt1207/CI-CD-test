package challenge.hello;

import java.util.Objects;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
class Information {

  private @Id @GeneratedValue Long id;
  private String info;
  
  Information() {}

  Information(String info) {
    this.info = info;
  }

  public Long getId() {
    return this.id;
  }

  public String getInfo() {
    return this.info;
  }

  
  public void setId(Long id) {
    this.id = id;
  }

  public void setInfo(String info) {
    this.info = info;
  }

  
  @Override
  public boolean equals(Object o) {

    if (this == o)
      return true;
    if (!(o instanceof Information))
      return false;
    Information information = (Information) o;
    return Objects.equals(this.id, information.id) && Objects.equals(this.info, information.info);
        
  }

  @Override
  public int hashCode() {
    return Objects.hash(this.id, this.info);
  }

  @Override
  public String toString() {
    return "Information{" + "id=" + this.id + ", info=" + this.info + "}";
  }
}
