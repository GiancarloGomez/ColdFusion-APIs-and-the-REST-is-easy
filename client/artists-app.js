var Artists = {
    // define our ui elements
    ui : {
        apiFrmModal : $('#api-form').modal({show:false,backdrop:'static'}),
        apiForm     : $('#apiFrm'),
        apiDetails  : $('#api-details'),
        app         : $('#artist-app'),
        table       : $('#artist-table'),
        results     : $('#artist-list'),
        formModal   : $('#artist-form').modal({show:false,backdrop:'static'}),
        theForm     : $('#artistFrm'),
        count       : $('#artist-count')
    },

    defaultUser : {
        firstName   : 'John',
        lastName    : 'Doe',
        email       : 'john.doe@fusedevelopments.com',
        phone       : '305-555-1234',
        address     : '125 Main Avenue',
        city        : 'Miami',
        state       : 'FL',
        postalCode  : '33012',
        thePassword : 'password'
    },

    // api url and credentials
    apiUrl      : sessionStorage.getItem('apiUrl'),
    apiKey      : sessionStorage.getItem('apiKey'),

    // holds our artists array
    artists : [],

    init : function(){
        var _this = this;
        // set up button actions
        _this.ui.app.on('click','button[data-do]',function(){
            switch (this.dataset.do){
                case 'edit':
                    _this.editArtist(this);
                break;
                case 'delete':
                    _this.deleteArtist(this);
                break;
                case 'api':
                    _this.showApiForm();
                break;
                case 'refresh':
                    $(this).find('i').addClass('fa-spin').end().blur();
                    _this.getAll(this);
                break;
                case 'add-dummy':
                    _this.addArtist(_this.defaultUser);
                break;
                default:
                    _this.addArtist();
                break;
            }
            return false;
        });
        // setup form submissions
        _this.ui.theForm.submit(()=>_this.submitArtistForm());
        _this.ui.apiForm.submit(()=>_this.submitApiForm());
        // make sure we have an apiUrl and apiKey defined
        if (!_this.apiUrl || !_this.apiKey){
            _this.showApiForm();
        } else {
            // fetch all artists
            _this.getAll();
        }
    },

    getAll : function(element){
        let _this = this;
        // using the fetch API
        fetch(_this.createRequest())
            .then(_this.handleErrors)
            .then(response => response.json())
            .then(response => {
                _this.artists = response.data;
                _this.renderArtists();
                _this.renderApiDetails();
                // close out api form if open
                _this.ui.apiFrmModal.modal('hide');
                // stop spin on refresh element if passed in
                if (element)
                    $(element).find('i').removeClass('fa-spin');
            })
            .catch(error => _this.handleCatch(error));
    },

    renderApiDetails : function(){
        this.ui.apiDetails.html(`
            <strong>URL :</strong> ${this.apiUrl} <br />
            <strong>KEY :</strong> ${this.apiKey}
        `);
    },

    renderArtists : function(){
        let _this   = this,
            str     = '';
        // loop thru each and append to string to render
        this.artists.forEach(artist => str += _this.renderArtist(artist));
        // render list
        _this.ui.results.html(str);
        // show interface
        _this.ui.app.addClass('on');
        // render count
        _this.renderArtistCount();
    },

    renderArtist : function(artist){
        var str = ` <tr>
                        <td>${artist.artistID}</td>
                        <td>
                            ${artist.firstName} ${artist.lastName}
                            <div class="visible-sm visible-xs">
                                ${artist.email ? `<a href="mailto:${artist.email}">${artist.email}</a><br />` : ``}
                                ${artist.phone ? `<a href="tel:${artist.phone}">${artist.phone}</a>` : ``}
                            </div>
                            <div class="visible-xs">
                                ${artist.address}<br />
                                ${artist.city}, ${artist.state} ${artist.postalCode}
                            </div>
                        </td>
                        <td class="hidden-sm hidden-xs">${artist.email ? `<a href="mailto:${artist.email}">${artist.email}</a>` : ``}</td>
                        <td class="hidden-sm hidden-xs text-nowrap">${artist.phone ? `<a href="tel:${artist.phone}">${artist.phone}</a>` : ``}</td>
                        <td class="hidden-xs">${artist.address}<br />${artist.city}, ${artist.state} ${artist.postalCode}</td>
                        <td class="text-right">
                            <button type="button" class="btn btn-primary" data-do="edit" data-id="${artist.artistID}"><i class="fa fa-pencil"></i></button>
                            <button type="button" class="btn btn-danger" data-do="delete" data-id="${artist.artistID}"><i class="fa fa-trash"></i></button>
                        </td>
                    </tr>`;
        // quick hack to remove any undefined string values
        return str.replace(/undefined/g,'');
    },

    renderArtistCount : function(){
        if (this.artists.length === 0){
            this.ui.table.addClass('hide');
            this.ui.count.html('There are no artists in the database.<br />Click on the button above to add your first Artist.');
        } else {
            this.ui.table.removeClass('hide');
            this.ui.count.html(this.artists.length + ' Artist' + (this.artists.length !== 1 ? 's' : ''));
        }
    },

    editArtist : function(element){
        let _this       = this,
            artistID    = parseInt(element.dataset.id),
            artist      = _this.artists.find( artist => artist.artistID === artistID);
        // fetch latest artist
        /*
        fetch(_this.createRequest('/' + element.dataset.id))
            .then(_this.handleErrors)
            .then(response => response.json())
            .then(response => _this.prepareArtistForm(response.data))
            .catch(error => _this.handleCatch(error));
        */
        // work with local data
        _this.prepareArtistForm(artist);
    },

    deleteArtist : function(element){
        var _this       = this,
            me          = $(element),
            artistID    = parseInt(element.dataset.id),
            index       = _this.artists.findIndex( artist => artist.artistID === artistID );
        openActionDialog({
            message : 'Are you sure you want to delete this artist?',
            callback : function (o){
                // do not really delete any artist below id 15
                if ( artistID > 15 ){
                    // send delete
                    fetch(_this.createRequest('/' + artistID,'DELETE'))
                        .then(_this.handleErrors)
                        .then(response => response.json())
                        .then(response => console.log(response))
                        .catch(error => _this.handleCatch(error));
                }
                // hide modal
                me.parents('tr').remove();
                _this.artists.splice(index,1);
                o.modal('hide');
                // render count
                _this.renderArtistCount();
            }
        });
    },

    addArtist : function(data = {}){
        this.prepareArtistForm(data);
    },

    prepareArtistForm : function (artist){
        document.artistFrm.artistID.value       = artist.artistID || '';
        document.artistFrm.firstName.value      = artist.firstName || '';
        document.artistFrm.email.value          = artist.email || '';
        document.artistFrm.phone.value          = artist.phone || '';
        document.artistFrm.lastName.value       = artist.lastName || '';
        document.artistFrm.address.value        = artist.address || '';
        document.artistFrm.city.value           = artist.city || '';
        document.artistFrm.state.value          = artist.state || '';
        document.artistFrm.postalCode.value     = artist.postalCode || '';
        document.artistFrm.thePassword.value    = artist.thePassword || '';
        // reset buttons
        formButtons(false,document.artistFrm);
        // open form
        this.ui.formModal.modal('show');
    },

    showApiForm : function(fromError){
        if(fromError === true)
            this.ui.apiFrmModal.find('.alert').removeClass('hide');
        else
            this.ui.apiFrmModal.find('.alert').addClass('hide');
        // reset buttons
        document.apiFrm.apiUrl.value = this.apiUrl;
        document.apiFrm.apiKey.value = this.apiKey;
        formButtons(false,document.apiFrm);
        this.ui.apiFrmModal.modal('show');
    },

    submitArtistForm : function(){
        let _this       = this,
            validate    = validateForm(document.artistFrm),
            artistID    = document.artistFrm.artistID.value,
            request;

        if (validate.err.length > 0) {
            openDialog(validate);
        } else {
            //create request
            request =   this.createRequest(
                            artistID === '' ? '' : '/' + artistID,
                            artistID === '' ? 'POST' : 'PUT',
                            'application/x-www-form-urlencoded',
                            this.ui.theForm.serialize()
                        );
            // post form
            fetch(request)
            .then(_this.handleErrors)
            .then(response => response.json())
            .then((response) => {
                // new artist
                if (artistID === ''){
                    // push new artist
                    _this.artists.push(response.data);
                    // lets make sure to sort before re-rendering
                    const alpha = _this.artists.sort((lastOne, nextOne) => {
                      const a = lastOne.firstName + lastOne.lastName;
                      const b = nextOne.firstName + nextOne.lastName;
                      return a > b ? 1 : -1;
                    });
                    // save sorted list back
                    _this.artists = alpha;
                }
                // existing artist
                else{
                    // find and update in array
                    const index = _this.artists.findIndex( artist => artist.artistID === response.data.artistID);
                    _this.artists[index] = response.data;
                }
                // hide modal
                _this.ui.formModal.modal('hide');
                // render artists again
                _this.renderArtists();
            })
            .catch(error => _this.handleCatch(error));
        }
        return false;
    },

    submitApiForm : function(){
        let validate = validateForm(document.apiFrm);
        if (validate.err.length > 0) {
            openDialog(validate);
        } else {
            // set current values
            this.apiUrl = document.apiFrm.apiUrl.value;
            this.apiKey = document.apiFrm.apiKey.value;
            // save to sessionStorage
            sessionStorage.setItem('apiUrl',this.apiUrl);
            sessionStorage.setItem('apiKey',this.apiKey);
            // process
            this.getAll();
        }
        return false;
    },

    createRequest : function(
        path        = '',
        method      = 'GET',
        contentType = 'text/plain',
        body        = null
    ){
        return new Request(this.apiUrl + path,{
            method      : method,
            mode        : 'cors',
            body        : body,
            headers     : new Headers({
                'Accept': 'application/json',
                'Content-Type' : contentType,
                'Authorization' : btoa(this.apiKey + ':')
            })
        });
    },

    handleErrors  : function(response){
        if (!response.ok)
            throw Error(response.statusText);
        return response;
    },

    handleCatch : function(error){
        // could not connect
        if (error.toString().indexOf('Failed to fetch') !== -1)
           this.showApiForm(true);
        else
            console.log(error);
    }
};

Artists.init();