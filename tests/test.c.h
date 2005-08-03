#ifndef __OPT_H__
#define __OPT_H__

#include <string>
#include <vector>

/*
=pod

=head1 Name

hoptions - A simple option parsing library

=head1 Description

With the C<hoptions> library one can do simple command line options parsing.
This library expects options in the following form:

=over 1

C<E<lt>optionE<gt>[=E<lt>valueE<gt>]>

=back

Samples:

=over 1

C<--help>E<lb>
C<--with-ldap-host=localhost>E<lb>

=back

Options are parsed case sensitive.  

=head2 Construction

=over 1

=head3 C<hoptions(int argc,char *argv[],const std::string & possible_options)>

Constructs a C<hoptions> object with the given arguments. C<possible_options> 
represents the known options. All known options are given as literals, without
the preceding '--'s; separated by pipes ('|'). 

Arguments that contain no '--', are appended to a vector of strings, of which 
hoptions derives (so hoptions can be treated like a std::vector).

=head3 C<hoptions(int argc,const char *argv[],const std::string & possible_options)>

Same functionality.

=back 

=head2 Getting options

=over 1

=head3 C<bool get(const std::string & key)>

Returns C<true>, if key exists.E<lb>
Returns C<false>, otherwise.

=head3 C<bool get(const std::string & key,std::string & value)>

Same as get(key), except that the value of key is retreived. If 
key has no value, C<value> will be the empty string (C<"">).

=head3 C<bool get(const std::string & key,int & value)>

Same as get(key), except that the value of key is retreived. If 
key has no value, C<value> will be zero (0).

=head3 C<bool get(const std::string & key,unsigned int & value)>

Same as get(key), except that the value of key is retreived. If 
key has no value, C<value> will be zero (0).

=head3 C<bool get(const std::string & key,double & value)>

Same as get(key), except that the value of key is retreived. If 
key has no value, C<value> will be zero (0.0).

=back

=head2 Error Handling

=over 1

=head3 C<bool ok(void)>

Returns C<true>, if the option parsing went well.E<lb>
Returns C<false>, otherwise.

=head3 C<const std::string & error(void)>

Returns the empty string, if the option parsing went well.E<lb>
Returns a description of the error that occured, otherwise.

=head3 C<void info(void)>

Prints the known options, parsed options and error status to stderr.

=back

=head1 Sample

=syn c,4

 #include <stdio.h>
 #include <hoptions.h>
 #include <string>
 
 
 int main(int argc,char *argv[]) {
	 std::string css="";
	 hoptions o(argc,argv,"help|stylesheet|version");
	 
	 if (!o.ok()) {
		 fprintf(stderr,"%s\n",ok.error().c_str());
		 exit(1);
	 }
	 else if (o.get("help")) {
		 fprintf(stderr,"usage: %s [--stylesheet=abc|--version] <file.in >file.out\n",argv[0]);
		 exit(0);
	 }
	 else if (o.get("version")) {
		 printf("v0.1\n");
		 exit(0);
	 }
	 
	 o.get("stylesheet",css);
	 
	 printf("<!-- stylesheet=%s -->\n",css.c_str());
	 
	 {
		 int i;
		 	for(i=0;i<o.size();i++) {
			 	printf("%s\n",o[i].c_str());
		 	}
	 }
	 
	 (...)
	 
 }
 
=head1 Author

Hans Oesterholt-Dijkema   E<lt> hans -at- elemental-programming *punt* org E<gt>

=head1 License

This program is released under the I<Elemental Programming Artistic License>.

=head1 Version

This is version @VERSION@ of the @PACKAGE@ package.

=head1 The code

This here represents the code.

=verbatim cxx,4 */
class hoptions : public std::vector<std::string> {
	private:
		std::vector<std::string>	_keys;
		std::vector<std::string>	_values;
		std::vector<std::string>    _known;
		bool						_ok;
		std::string					_error_msg;
	private:
		std::string trim(const std::string & s);
		void        init(int argc,const char *argv[],const std::string & known_options);
	public:
		hoptions(int argc,const char *argv[],const std::string & known_options="");
		hoptions(int argc,char *argv[],const std::string & known_options="");
	public:
		bool 				ok(void);
		const std::string & error(void);
	public:
		bool get(const std::string & key,std::string & value);
		bool get(const std::string & key,int & value);
		bool get(const std::string & key,double & value);
		bool get(const std::string & key,unsigned int & value);
		bool get(const std::string & key);
	public:
	    void info(void);
};

/*=verbatim end

Yes, here we had the code.

=head1 License

This program is released under the I<Elemental Programming Artistic License>.

=cut
*/

#endif
