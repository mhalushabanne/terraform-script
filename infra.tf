provider "aws" {

        access_key = "AKIA4S3O4GIBHITX32OF"
        secret_key = "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"
        region = "ap-south-1"

}

#create vpc for qa uat and dev env 

resource "aws_vpc" "vpc" {

        cidr_block = "10.10.0.0/16"
        tags = {

        Name = "vpc-1"
}
}

#creating subnets for dev 

resource "aws_subnet" "dev" {

        vpc_id = "${aws_vpc.vpc.id}"
        cidr_block = "10.10.1.0/24"
        availability_zone = "ap-south-1a"
        tags = {
                Name = "subnet-1 "
		Namw = "dev"
        }
}

resource "aws_subnet" "qa" {
 

        vpc_id = "${aws_vpc.vpc.id}"
        cidr_block = "10.10.2.0/24"
        availability_zone = "ap-south-1b"
        tags = {
                Name = "subnet-2 "
                Name = "qa"
        }
}

resource "aws_subnet" "uat" {
	

	vpc_id = "${aws_vpc.vpc.id}"
	cidr_block = "10.10.3.0/24"
	availability_zone = "ap-south-1a"
	tags = {
		Name = "subnet-3"
		Name = "uat"
	}
}

resource "aws_subnet" "master" {


        vpc_id = "${aws_vpc.vpc.id}"
        cidr_block = "10.10.4.0/24"
        availability_zone = "ap-south-1b"
        tags = {
                Name = "subnet-4"
        }
}


###########creating igw attached to vpc

resource "aws_internet_gateway" "igw" {

        vpc_id = "${aws_vpc.vpc.id}"
        tags = {

        Name = "igw"
}

}
####creating rt table for subnet

resource "aws_route_table" "pub-rt" {

        vpc_id = "${aws_vpc.vpc.id}"
        tags = {

        Name = "pub-rt"
}

        route {

                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.igw.id}"

        }
	


}

#subnet associations for different env

resource "aws_route_table_association" "one" {


        subnet_id = "${aws_subnet.dev.id}"
        route_table_id = "${aws_route_table.pub-rt.id}"

}

resource "aws_route_table_association" "two" {


        subnet_id = "${aws_subnet.qa.id}"
        route_table_id = "${aws_route_table.pub-rt.id}"

}
resource "aws_route_table_association" "three" {


        subnet_id = "${aws_subnet.uat.id}"
        route_table_id = "${aws_route_table.pub-rt.id}"

}

resource "aws_route_table_association" "four" {


        subnet_id = "${aws_subnet.master.id}"
        route_table_id = "${aws_route_table.pub-rt.id}"

}



resource "aws_instance" "dev1" {

        ami = "ami-06e6b44dd2af20ed0"
        instance_type = "t2.micro"
        subnet_id = "${aws_subnet.dev.id}"
        key_name = "project1"
	security_groups = [aws_security_group.devsg.id]


	tags = {
	
		Name = "dev"
#######	security_groups = "${aws_security_group.devsg.id}"
}
}
resource "aws_instance" "qa1" {

        ami = "ami-06e6b44dd2af20ed0"
        instance_type = "t2.micro"
        subnet_id = "${aws_subnet.qa.id}"
        key_name = "project1"

	tags = {
		
		Name = "QA"
}
}
resource "aws_instance" "uat1" {

        ami = "ami-06e6b44dd2af20ed0"
        instance_type = "t2.micro"
        subnet_id = "${aws_subnet.uat.id}"
        key_name = "project1"

	tags = {
			
		Name ="Uat"
}
}
resource "aws_instance" "master1" {

        ami = "ami-06e6b44dd2af20ed0"
        instance_type = "t2.micro"
        subnet_id = "${aws_subnet.master.id}"
        key_name = "project1"

	tags = {
		Name = "master"
}

}

resource "aws_eip" "my-eip1" {

        instance = "${aws_instance.dev1.id}"
        tags = {

                Name = "my-eip1"
                }

}
resource "aws_eip" "my-eip2" {

        instance = "${aws_instance.qa1.id}"
        tags = {

                Name = "my-eip2"
                }

}
resource "aws_eip" "my-eip3" {

        instance = "${aws_instance.uat1.id}"
        tags = {

                Name = "my-eip3"
                }

}
resource "aws_eip" "my-eip4" {

        instance = "${aws_instance.master1.id}"
        tags = {

                Name = "my-eip4"
                }

}




resource "aws_security_group" "devsg" {
  name        = "vpc-tera"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
 
  }
ingress {
    description      = "tomcat"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }

#  egress {
 #   from_port        = 0
#    to_port          = 65535
 #   protocol         = "-1"
  #  cidr_blocks      = ["0.0.0.0/0"]
 # }

  tags = {
    Name = "allow_tls"
  }
}
