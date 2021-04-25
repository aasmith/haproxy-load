# Install analysis-specific tools

sudo yum install -y cairo-devel pango-devel

curl -OJL "http://downloads.sourceforge.net/project/gnuplot/gnuplot/5.4.1/gnuplot-5.4.1.tar.gz"
tar zxvf gnuplot-5.4.1.tar.gz

pushd gnuplot-5.4.1
./configure --with-cairo
make
sudo make install
popd
